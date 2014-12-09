require 'yaml'
require 'fileutils'
require 'kinetic_logger'
require 'kinetic_server'

module KineticRuby

  class Proto

    def initialize(log_level = KineticRuby::Logger::LOG_LEVEL_INFO)
      require_relative "protobuf/kinetic.pb"
      @message_out = nil
      @message_in = nil
      @logger = KineticRuby::Logger.new(log_level)
    end

    def decode(buf)
      @message_in = Seagate::Kinetic::Message.decode(buf)

      @logger.log
      @logger.log "#{@message_in.class} - Decoding"
      @logger.log  "-----------------------------------"

      @logger.log "  command:"
      @message_in.command.to_yaml.each_line{|l| @logger.log "    #{l}"}
      @logger.log
    end

    def test_encode
      pb = Seagate::Kinetic::Message.new

      @logger.log
      @logger.log "#{pb.class} - Encoding"
      @logger.log  "---------------------------------------"

      @logger.log_verbose "  fields:"
      pb.fields.sort.each{|f| @logger.log_verbose "    #{f}"}
      @logger.log_verbose

      @logger.log_verbose "  hmac:"
      pb.hmac = "0123456789ABCDEF0123"
      @logger.log_verbose "    #{pb.hmac.inspect}"
      @logger.log_verbose

      @logger.log "  command:"
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
            statusMessage: "The specified HMAC security algorithm does not exist!",
            detailedMessage: "YOUCH!"
          ),
      )
      pb.command.to_yaml.each_line{|l| @logger.log("    #{l}")}
      @logger.log

      @message_out = pb

      @logger.log "  encoded:"
      encoded = pb.encode
      @logger.log_verbose
      @logger.log_verbose "    Inspection: #{encoded.inspect}"
      @logger.log_verbose
      @logger.log_verbose "    Content:"
      encoded.to_yaml.each_line{|l| @logger.log_verbose "    #{l}"}
      @logger.log_verbose
      @logger.log "    Length: #{encoded.length} bytes"
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
      @logger.log "Kinetic Protocol protobuf encode/decode test passed!"
      @logger.log
    end

  end
end
