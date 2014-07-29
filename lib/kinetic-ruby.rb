require_relative 'kinetic_logger'
require_relative 'kinetic_proto'
require_relative 'kinetic_server'

module KineticRuby

  VERSION = '0.3.4'
  DEFAULT_KINETIC_PORT = 8123
  TEST_KINETIC_PORT = 8999

  kp_tag = ''
  FileUtils.cd "./vendor/kinetic-protocol" do
    kp_tag = 'v' + `git describe --tags`.strip
    kp_tag = "<Unknown Kinetic Protocol version!>" if kp_tag !~ /^v\d+\.\d+\.\d+/
  end
  KINETIC_PROTOCOL_VERSION = kp_tag

end
