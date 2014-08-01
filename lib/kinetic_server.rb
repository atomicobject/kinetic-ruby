require 'socket'

$kinetic_server = nil

module KineticRuby

  DEFAULT_KINETIC_PORT = 8123
  TEST_KINETIC_PORT = 8999

  class Server

    attr_reader :host, :port, :connected

    def initialize(port = DEFAULT_KINETIC_PORT, log_level=Logger::LOG_LEVEL_INFO)
      @host = 'localhost'
      @port ||= DEFAULT_KINETIC_PORT
      raise "Invalid Kinetic test server port specified (port: #{port})" if !@port || @port < 0
      @logger = Logger.new(log_level)
      @proto = Proto.new(@logger)
      @server = nil
      @worker = nil
      @clients = []
      @logger.log "Kinetic Ruby test device server started!"
    end

    def connected
      !@server.nil?
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
      return unless @server.nil?

      @server = TCPServer.new(@host, @port)

      # Setup handler for signaled shutdown (via ctrl+c)
      trap("INT") do
        @logger.log "Kinetic Test Server: INT triggered Kintic Test Server shutdown"
        shutdown
      end

      # Create worker thread for test server to run in so we can continue
      @worker = Thread.new do
        @logger.log "Kinetic Test Server: Listening for Kinetic clients..."
        loop do
          client = nil
          begin
            client, client_info = @server.accept
          rescue Exception => e
            @logger.log "Kinetic Test Server: EXCEPTION during accept!\n" +
              "  #{e.inspect}\n" +
              "  #{e.message}\n  #{e.backtrace.join("  \n")}"
            next if client.nil?
          end

          next if client.nil?

          @logger.log "Kinetic Test Server: Connected to #{client.inspect}"
          request = ''
          data = nil
          pdu = nil
          disconnect = false

          while !disconnect
            begin
              data = client.recv(1024)
            rescue IO::WaitReadable
              @logger.log("IO:WaitReadable");
              IO.select([client])
              retry
            rescue Exception => e
              @logger.logv "Kinetic Test Server: EXCEPTION during receive!\n" +
                "  #{e.inspect}\n" +
                "  #{e.message}\n  #{e.backtrace.join("  \n")}"
              disconnect = true
              next
            end

            if (data.nil? || data.empty?)
              @logger.log "Kinetic Test Server: Client #{client.inspect} disconnected!"
              disconnect = true
              next
            end

            # Incrementally parse PDU until complete
            if request[0] == KineticRuby::Proto::VERSION_PREFIX && request.length >= 9
              pdu ||= PDU.new(@Logger)
              pdu.update(request)
            end

            # Otherwise, handle custom test requests
            if pdu.nil?
              request_match = request.match(/^read\((\d+)\)/)
              if request_match
                len = request_match[1].to_i
                response = 'G'*len
                @logger.log "Kinetic Test Server: Responding to 'read(#{len})' w/ '#{response}'"
                client.write response
                request = ''
              elsif request =~ /^readProto()/
                response = @proto.test_encode
                @logger.log "Kinetic Test Server: Responding to 'read(#{len})' w/ dummy @protobuf (#{response.length} bytes)"
                client.write response
                request = ''
              end
            end

            @logger.log "Kinetic Test Server: Client #{client.inspect} disconnected!"
            client.close
            @logger.log "Kinetic Test Server: Client connection shutdown successfully"
          end
        end
      end
    end

    def shutdown
      return if @server.nil?
      @logger.log "Kinetic Test Server: shutting down..."
      if @worker
        @worker.exit
        @worker.join(2)
        @worker = nil
      end
      if @server
        @server.close
        @server = nil
      end
      @logger.log "Kinetic Test Server: shutdown complete"
    end

  end
end
