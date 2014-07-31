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
      @listeners = []
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

      @server = TCPServer.new @port
      @listeners = []

      # Setup handler for signaled shutdown (via ctrl+c)
      trap("INT") do
        @logger.log "Kinetic Test Server: INT triggered Kintic Test Server shutdown"
        shutdown
      end

      # Create worker thread for test server to run in so we can continue
      @worker = Thread.new do
        @logger.log "Kinetic Test Server: Listening for Kinetic clients..."
        loop do

          @listeners << Thread.start(@server.accept) do |client|
            
            @logger.log "Kinetic Test Server: Connected to #{client.inspect}"
            @abort = false
            @clients << client
            request = ''
            data = nil
            pdu = nil

            while !@abort

              begin
                data = client.recvfrom(1)
              rescue IO::WaitReadable
                IO.select([client])
                retry
              # rescue Errno::ECONNRESET =>
              rescue Exception => e
                @logger.log "Kinetic Test Server: EXCEPTION!\n  #{e.message}\n  #{e.backtrace.inspect}"
                @abort = true
                next
              end

              if (data.nil? || data.empty?)
                @logger.log "Kinetic Test Server: Client #{client.inspect} disconnected!"
                @abort = true
                next
              end

              # Incrementally parse PDU until complete
              if request[0] == KineticProto::VERSION_PREFIX && request.length >= 9
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

            end

            @logger.log "Kinetic Test Server: Client #{client.inspect} disconnected!"
          end
        end
      end

    end

    def shutdown
      return if @server.nil?
      @logger.log "Kinetic Test Server: shutting down..."
      @listeners.each do |client|
        client.join(0.3) if client.alive?
      end
      @listeners = []
      @worker.exit
      @worker = nil
      @server.close
      @server = nil
      @logger.log "Kinetic Test Server: shutdown complete"
    end

  end
end
