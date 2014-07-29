require_relative 'kinetic-ruby'

$kinetic_server = nil

module KineticRuby

  class Server

    def initialize(port = nil, logger = nil)
      port ||= DEFAULT_KINETIC_PORT
      raise "Invalid Kinetic test server port specified (port: #{port})" if !port || port < 0
      @port = port
      @logger = logger
      @server = nil
      @worker = nil
      @listeners = []
    end

    def report(message='')
      $stderr.flush
      $stdout.flush
      puts message
      $stderr.flush
      $stdout.flush
    end

    def report_banner(message)
      report "\n#{message}\n#{'='*message.length}\n\n"
    end

    def report_buffer(buf)
      bytes = buf.bytes
      row_len = 16
      report "Raw Data (length=#{buf.count}):"
      while !bytes.empty?
        row_len = bytes.count >= row_len ? row_len : bytes.count
        report "  row_len: #{row_len}"
        row = bytes.slice!(row_len)
        report "  row: #{row.inspect}"
        msg = "  "
        row.each do |b|
          msg += sprintf("0x%02X", b)
        end
        report msg
      end
      report
    end

    def start
      return unless @server.nil?

      @server = TCPServer.new @port
      @listeners = []

      # Setup handler for signaled shutdown (via ctrl+c)
      trap("INT") do
        report "Kinetic Test Server: INT triggered Kintic Test Server shutdown"
        shutdown
      end

      # Create worker thread for test server to run in so we can continue
      @worker = Thread.new do
        report "Kinetic Test Server: Listening for Kinetic clients..."
        loop do
          @listeners << Thread.start(@server.accept) do |client|
            report "Kinetic Test Server: Connected to #{client.inspect}"
            request = ""
            while request += client.getc # Read characters from socket

              request_match = request.match(/^read\((\d+)\)/)

              if request_match
                len = request_match[1].to_i
                response = "G"*len
                report "Kinetic Test Server: Responding to 'read(#{len})' w/ '#{response}'"
                client.write response
                request = ''

              elsif request =~ /^readProto()/
                proto = KineticRuby::Proto.new
                response = proto.encode_test_message
                report "Kinetic Test Server: Responding to 'read(#{len})' w/ dummy protobuf (#{response.length} bytes)"
                client.write response
                request = ''

              # elsif request.length > 20
              #   report_banner "Received unknown data: length=#{request.length}"
              #   report "  requst.inspect"
              #   report_buffer(request)
              # end

            end
            report "Kinetic Test Server: Client #{client.inspect} disconnected!"
          end
        end
      end

    end

    def shutdown
      return if @server.nil?
      report "Kinetic Test Server: shutting down..."
      @listeners.each do |client|
        client.join(0.3) if client.alive?
      end
      @listeners = []
      @worker.exit
      @worker = nil
      @server.close
      @server = nil
      report "Kinetic Test Server: shutdown complete"
    end

  end
end
