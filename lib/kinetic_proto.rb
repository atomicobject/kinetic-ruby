require 'yaml'
require 'fileutils'
require_relative 'kinetic_logger'
require_relative 'kinetic_server'

module KineticRuby

  class Proto

    kp_tag = ''
    FileUtils.cd "./vendor/kinetic-protocol" do
      kp_tag = 'v' + `git describe --tags`.strip
      kp_tag = "<Unknown Kinetic Protocol version!>" if kp_tag !~ /^v\d+\.\d+\.\d+/
    end
    PROTOCOL_VERSION = kp_tag
    VERSION_PREFIX = 'F'

    def initialize(logger)
      @logger = logger
      require_relative 'protobuf/kinetic.pb'
      @message_out = nil
      @message_in = nil
    end

    def decode(buf)
      @message_in = Seagate::Kinetic::Message.decode(buf)
      @logger.log
      @logger.log("\n#{@message_in.class} - Decoding", true)
      @logger.log '  command:'
      @message_in.command.to_yaml.each_line{|line| @logger.log '    ' + line}
      @logger.log
    end

    def test_encode
      pb = Seagate::Kinetic::Message.new

      @logger.log("\n#{pb.class} - Encoding", true)
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
      @logger.log_verbose "  hmac:\n    #{pb.hmac}"

      @logger.log '  command:'
      pb.command.to_yaml.each_line{|l| @logger.log("    #{l}")}
      @logger.log '  encoded:'
      @logger.log '    Length: ' + encoded.length.to_s + ' bytes'

      @logger.log_verbose "    Raw:\n      #{encoded.inspect}"
      @logger.log_verbose "    Content:"
      encoded.to_yaml.each_line{|line| @logger.log_verbose "      #{line}"}
      
      @logger.log

      return encoded
    end

    def test_kinetic_proto
      msg = test_encode
      decode msg

      if @message_in != @message_out
        @logger.log_err "Inbound/outbound messages do not match!\n\n"
        raise "\nKinetic Protocol message roundtrip FAILED!\n\n"
      end

      @logger.log
      @logger.log 'Kinetic Protocol protobuf encode/decode test passed!'
      @logger.log
    end

  end
end
