$kinetic_server = nil
require 'kinetic_constants'

module KineticRuby

  class Client
    def initialize(socket, addr_info, logger)
      @socket = socket
      @addr = addr_info
      @logger = logger
    end

    # Shutdown a client socket
    def close
      return unless @socket
      @logger.log "Client socket #{@socket.inspect} disconnected!"
      @socket.close
      @socket = nil
      @logger.logv "Client #{@socket.inspect} connection shutdown successfully"
    end

    # Return formatted address '<address>:<port>' for the socket
    def self.address(socket)
      return nil unless socket
      raise "Socket appears to be disconnected!" if !socket.remote_address
      "#{socket.remote_address.ip_address}:#{socket.remote_address.ip_port}"
    end

    # Return formatted address '<address>:<port>' of the client
    def address
      Client.address(@socket)
    end

    # Wait to receive data from the client
    # @param max_len  Maximum number of bytes to receive
    # @returns        Received data (length <= max_len) or nil upon failure
    def receive(max_len=nil)
      max_len ||= 1024

      begin
        data = @socket.recv(max_len)
      rescue IO::WaitReadable
        @logger.logv 'Retrying receive...'
        IO.select([@socket])
        retry
      rescue Exception => e
        if e.class != 'IOError' && e.message != 'closed stream'
          @logger.log_exception(e, 'EXCEPTION during receive!')
        end
      end

      if (data.nil? || data.empty?)
        @logger.log "Client #{@socket.inspect} disconnected!"
        data = ''
      else
        @logger.log "Received #{data.length} bytes"
      end

      return data
    end
    alias recv receive # provide 'standard' socket method as well

    # Send data to the client
    def send(data)
      @socket.write(data)
    end
    alias write send # provide 'standard' socket method as well

  end

  class ClientProvider
    def initialize(host, port, logger)
      @host = host
      @port = port
      @logger = logger
      @server = nil
    end

    # @brief    Listen for connection
    # @return   Returns a Client upon connection, nil upon failure
    def accept
      client = nil
      @server ||= TCPServer.new(@host, @port)
      
      begin
        client = Client.new(@server.accept)
      rescue Exception => e
        @logger.log_exception(e, 'EXCEPTION during accept!') 
      end

      @logger.log 'Client dropped off!' if client.nil?
      
      return client
    end

    # @brief    Shutdown the socket server
    def shutdown
      return if @server.nil?
      @server.close
      @server = nil
    end

    # @brief        Starts a TCP socket server and yields block for each client (sequential)
    # @param host   Host name or IPv4/6 address
    # @param port   Port to listen on
    # @param logger Logger to output to
    def self.each_client(host, port, logger)
      raise "No block supplied!" unless block_given?
      logger.log "Listening for clients..."

      # Service clients, one at a time (for now at least)
      begin
        Socket.tcp_server_loop(host, port) do |socket, addr|
          
          logger.log "New client connected on socket #{socket.inspect}"
          
          client = Client.new(socket, addr, logger)
          raise "Failed to connect to client!" unless client
          logger.log "Connected to #{client.address}"

          begin
            # Execute the supplied block with the connected client
            yield(client, logger)
            logger.log "Done servicing client #{client.address}"
          ensure
            logger.log "Closing client socket..."
            # Make sure the client gets closed, since tcp_server_loop does NOT!
            client.close
            logger.log "Client socket shutdown!"
          end
          logger.log "Done with client #{client.address}"
        end

      rescue Exception => e
        logger.log_exception(e, 'EXCEPTION during listen!')
      end 

      logger.log "Done listening for clients!"
    end

  end

  class Server

    attr_reader :host, :port, :connected

    def initialize(port = DEFAULT_KINETIC_PORT, log_level=Logger::LOG_LEVEL_INFO)
      @host = 'localhost'
      @port ||= DEFAULT_KINETIC_PORT
      raise "Invalid server port specified: #{port}" if !@port || @port < 0
      @logger = Logger.new(log_level)
      @logger.prefix = 'KineticSim: '
      @worker = nil
      @logger.log 'Kinetic device test server started!'
    end

    def report_buffer(buf)
      bytes = buf.bytes
      row_len = 16
      @logger.log "Raw Data (length=#{buf.count}):"
      while !bytes.empty?
        row_len = bytes.count >= row_len ? row_len : bytes.count
        @logger.log "  row_len: #{row_len}"
        row = bytes.slice!(row_len)
        @logger.log "  row: #{row.inspect}"
        msg = "  "
        row.each do |b|
          msg += sprintf("0x%02X", b)
        end
        @logger.log msg
      end
      report
    end

    def start
      return unless @worker.nil?

      # Setup handler for signaled shutdown (via ctrl+c)
      trap("INT") do
        @logger.log "INT triggered shutdown"
        shutdown
      end

      # Create background thread for processing client requests
      @worker = Thread.new do
        
        # Service client connections (sequentially)
        ClientProvider.each_client(@host, @port, @logger) do |client|

          request = ''
          pdu = nil
          connected = true
          raw_proto = []

          # Process requests while client available
          while connected && (data = client.receive)
            if data.nil? || data.empty?
              connected = false
              break
            end

            # Append received data to request for processing
            request += data

            # Incrementally parse PDU until complete
            if PDU.valid_header? request
              @logger.log 'Receiving a PDU...'
              raw_pdu = request.bytes.map{|b| sprintf("%02X", b)}.join('')
              @logger.log "  request[#{request.length}]: #{raw_pdu}"
              pdu ||= PDU.new(@logger)
              if pdu.parse(request)
                @logger.log "Received PDU successfully!"
              else
                @logger.log "Waiting on remainder of PDU..."
              end

            # Otherwise, handle custom test requests
            elsif pdu.nil?
              @logger.logv "Checking for custom request: '#{request}'"
              
              # Handle raw protobuf.. for tests
              if !raw_proto.empty? || request.match(/^\n/)
                @logger.log "Appears to be a standalone protobuf incoming..."
                raw_proto ||= []
                raw_proto += request.bytes
                @logger.log "  protobuf: (#{raw_proto.length} bytes)"
                request = ''
              
              # Handle request for read(num_bytes), and respond with num_bytes of dummy data
              elsif request_match = request.match(/^read\((\d+)\)/)
                len = request_match[1].to_i
                response = 'G'*len
                @logger.log "Responding to 'read(#{len})' w/ '#{response}'"
                client.send response
                request = ''
              
              # Handle request for readProto(), and respond with canned Kinetic protobuf
              elsif request =~ /^readProto()/
                response = Proto.new(@logger).test_encode
                @logger.log "Responding to 'read(#{len})' w/ dummy protobuf (#{response.length} bytes)"
                client.send response
                request = ''
              
              # Report not enough data yet to make a call...
              elsif request.match(/^read/) && data.length < 7
                @logger.log "no command match for request: '#{request}' (...yet)";

              # Otherwise, report unknown request received!
              else
                @logger.log "Unknown request! Aborting..."
                request = ''
                connected = false
              end
            end

          end #request service loop pass

          @logger.log "Disconnecting from client..."

        end #client connection

        @logger.log "Client listener shutting down..."
      end #worker thread

      @logger.log "Listener shutdown successfully!"

    end

    def shutdown
      return if @worker.nil?
      @logger.log 'shutting down...'
      if @worker
        @worker.exit
        @worker.join 2.0
        @worker = nil
      end
      @logger.log 'shutdown complete'
    end

  end
end
