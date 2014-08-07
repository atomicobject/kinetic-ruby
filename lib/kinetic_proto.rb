require 'yaml'

module KineticRuby

  class Proto

    VERSION_PREFIX = 'F'

    def initialize(logger)
      @logger = logger
      @message_out = nil
      @message_in = nil
    end

    def self.decode(buf, indent=0, logger=nil)
      msg = Seagate::Kinetic::Message.decode(buf)

      # Log the decoded protobuf
      if logger
        orig_prefix = logger.prefix
        add_prefix = (indent.class == Fixnum) ? (' '*indent) : indent
        add_prefix = ' ' * indent
        logger.prefix = logger.prefix + add_prefix
        logger.log 'message:'
        logger.prefix = logger.prefix + '  '
        self.to_yaml(msg).each_line{|line| logger.log(line) }
        logger.prefix = orig_prefix
        logger.log
      end

      return msg
    end

    def decode(buf, indent=0)
      @message_in = Proto.decode(buf, indent, @logger)
    end

    def self.to_yaml(msg)
      yaml = "message:\n"
      msg.to_yaml.each_line{|line| yaml += "  #{line}"}
      return yaml
    end

    def to_yaml(msg)
      self.to_yaml(msg)
    end

    def test_encode
      pb = Seagate::Kinetic::Message.new
      @logger.log
      @logger.log("#{pb.class} - Encoding", true)
      pb.hmac = '0123456789ABCDEF0123'
      pb.command = Seagate::Kinetic::Message::Command.new(
        header: Seagate::Kinetic::Message::Header.new(
          clusterVersion: 0x1122334455667788,
          identity:       0x1234567898654321
          ),
        body: Seagate::Kinetic::Message::Body.new(
          keyValue: Seagate::Kinetic::Message::KeyValue.new(
              key: "KeYvAl"
            )
          ),
        status: Seagate::Kinetic::Message::Status.new(
            code: Seagate::Kinetic::Message::Status::StatusCode::NO_SUCH_HMAC_ALGORITHM,
            statusMessage: 'The specified HMAC security algorithm does not exist!',
            detailedMessage: 'YOUCH!'
          ),
      )
      encoded = pb.encode
      @message_out = pb

      @logger.log_verbose '  fields:'
      pb.fields.sort.each{|f| @logger.log_verbose("    #{f}")}
      @logger.log_verbose "  hmac:"
      @logger.log_verbose "    #{pb.hmac}"

      @logger.log '  command:'
      pb.command.to_yaml.each_line{|l| @logger.log("    #{l}")}
      @logger.log '  encoded:'
      @logger.log '    Length: ' + encoded.length.to_s + ' bytes'

      @logger.log_verbose "    Raw:"
      @logger.log_verbose "      #{encoded.inspect}"
      @logger.log_verbose "    Content:"
      encoded.to_yaml.each_line{|line| @logger.log_verbose "      #{line}"}
      
      @logger.log

      return encoded
    end

    def test_kinetic_proto
      msg = test_encode

      @logger.log
      @logger.log("Decoded Message", true)
      decode(msg, 2)

      if @message_in != @message_out
        @logger.log_err "Inbound/outbound messages do not match!"
        @logger.log_err
        raise "\nKinetic Protocol message roundtrip FAILED!\n\n"
      end

      @logger.log
      @logger.log 'Kinetic Protocol protobuf encode/decode test passed!'
      @logger.log
    end

  end
end
