require_relative "protobuf/kinetic.pb"
require 'yaml'

class KineticRuby

  def initialize
    @message_out = nil
    @message_in = nil
  end

  def encode_test_message
    encode
  end

  def test_kinetic_proto
    msg = encode
    decode msg
  end

private

  def encode
    pb = Seagate::Kinetic::Message.new

    puts "\n\n"
    puts "Seagate::Kinetic::Message - Encoding"
    puts  "---------------------------------------"

    puts "  fields:"
    pb.fields.sort.each{|f| puts "    #{f}"}
    puts

    puts "  hmac:"
    pb.hmac = "0123456789ABCDEF0123"
    puts "    #{pb.hmac.inspect}"
    puts

    puts "  command:"
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
    pb.command.to_yaml.each_line{|l| puts "    #{l}"}
    @message_out = pb
    puts

    puts "  encoded:"
    encoded = pb.encode
    puts
    puts "    Inspection: #{encoded.inspect}"
    puts
    puts "    Content:"
    encoded.to_yaml.each_line{|l| puts "    #{l}"}
    puts

    return encoded
  end

  def decode(buf)
    puts
    puts "Seagate::Kinetic::Message - Decoding"
    puts  "-----------------------------------"

    @message_in = Seagate::Kinetic::Message.decode(buf)
    puts "  command:"
    @message_in.command.to_yaml.each_line{|l| puts "    #{l}"}
    puts

    raise "Kinetic Protocol message roundtrip FAILED!" if @message_in != @message_out
    puts "Kinetic Protocol message roundtrip SUCCESS!"
  end

end
