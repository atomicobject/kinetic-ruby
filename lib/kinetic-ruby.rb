require_relative "protobuf/kinetic.pb"
require 'yaml'

class KineticRuby

  LOG_LEVELS = [
    LOG_LEVEL_NONE = 0,
    LOG_LEVEL_ERROR = 1,
    LOG_LEVEL_INFO = 2,
    LOG_LEVEL_VERBOSE = 3,
  ]

  def initialize
    @message_out = nil
    @message_in = nil
    @log_level = LOG_LEVEL_NONE
  end

  def log_level=(level)
    if !LOG_LEVELS.include? level
      raise "\nInvalid LOG_LEVEL specified!\nValid levels:\n\t" +
        LOG_LEVELS.map{|l|"#{self.class}::#{l}"}.join("\n\t") + "\n\n"
    end
    @log_level = level
  end

  def encode_test_message
    encode
  end

  def test_kinetic_proto
    msg = encode
    decode msg
    puts
    puts "Kinetic Protocol protobuf encode/decode test passed!"
  end

private

  def log_err(msg='')
    log_message(msg, $stderr) if @log_level >= LOG_LEVEL_ERROR
  end

  def log_info(msg='')
    log_message(msg) if @log_level >= LOG_LEVEL_INFO
  end

  alias log log_info

  def log_verbose(msg='')
    log_message(msg) if @log_level >= LOG_LEVEL_VERBOSE
  end

  def log_message(msg='', stream=$stdout)
    $stderr.flush
    stream.flush
    stream.puts msg
    stream.flush
  end

  def encode
    pb = Seagate::Kinetic::Message.new

    log
    log "#{pb.class} - Encoding"
    log  "---------------------------------------"

    log_verbose "  fields:"
    pb.fields.sort.each{|f| log_verbose "    #{f}"}
    log_verbose

    log_verbose "  hmac:"
    pb.hmac = "0123456789ABCDEF0123"
    log_verbose "    #{pb.hmac.inspect}"
    log_verbose

    log "  command:"
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
    pb.command.to_yaml.each_line{|l| log("    #{l}")}
    log

    @message_out = pb

    log "  encoded:"
    encoded = pb.encode
    log_verbose
    log_verbose "    Inspection: #{encoded.inspect}"
    log_verbose
    log_verbose "    Content:"
    encoded.to_yaml.each_line{|l| log_verbose "    #{l}"}
    log_verbose
    log "    Length: #{encoded.length} bytes"
    log

    return encoded
  end

  def decode(buf)

    @message_in = Seagate::Kinetic::Message.decode(buf)

    log
    log "#{@message_in.class} - Decoding"
    log  "-----------------------------------"

    log "  command:"
    @message_in.command.to_yaml.each_line{|l| log "    #{l}"}
    log

    if @message_in != @message_out
      log_err "Inbound/outbound messages do not match!\n\n"
      raise "\nKinetic Protocol message roundtrip FAILED!\n\n"
    end

    log "Kinetic Protocol message roundtrip SUCCESS!"
  end

end
