## Generated from kinetic.proto for com.seagate.kinetic.proto
require "beefcake"

module Seagate
  module Kinetic

    class Message
      include Beefcake::Message

      module Synchronization
        INVALID_SYNCHRONIZATION = -1
        WRITETHROUGH = 1
        WRITEBACK = 2
        FLUSH = 3
      end

      module Algorithm
        INVALID_ALGORITHM = -1
        SHA1 = 1
        SHA2 = 2
        SHA3 = 3
        CRC32 = 4
        CRC64 = 5
      end

      module MessageType
        INVALID_MESSAGE_TYPE = -1
        GET = 2
        GET_RESPONSE = 1
        PUT = 4
        PUT_RESPONSE = 3
        DELETE = 6
        DELETE_RESPONSE = 5
        GETNEXT = 8
        GETNEXT_RESPONSE = 7
        GETPREVIOUS = 10
        GETPREVIOUS_RESPONSE = 9
        GETKEYRANGE = 12
        GETKEYRANGE_RESPONSE = 11
        GETVERSION = 16
        GETVERSION_RESPONSE = 15
        SETUP = 22
        SETUP_RESPONSE = 21
        GETLOG = 24
        GETLOG_RESPONSE = 23
        SECURITY = 26
        SECURITY_RESPONSE = 25
        PEER2PEERPUSH = 28
        PEER2PEERPUSH_RESPONSE = 27
        NOOP = 30
        NOOP_RESPONSE = 29
        FLUSHALLDATA = 32
        FLUSHALLDATA_RESPONSE = 31
      end

      class Command
        include Beefcake::Message
      end

      class Header
        include Beefcake::Message
      end

      class Body
        include Beefcake::Message
      end

      class Status
        include Beefcake::Message

        module StatusCode
          INVALID_STATUS_CODE = -1
          NOT_ATTEMPTED = 0
          SUCCESS = 1
          HMAC_FAILURE = 2
          NOT_AUTHORIZED = 3
          VERSION_FAILURE = 4
          INTERNAL_ERROR = 5
          HEADER_REQUIRED = 6
          NOT_FOUND = 7
          VERSION_MISMATCH = 8
          SERVICE_BUSY = 9
          EXPIRED = 10
          DATA_ERROR = 11
          PERM_DATA_ERROR = 12
          REMOTE_CONNECTION_ERROR = 13
          NO_SPACE = 14
          NO_SUCH_HMAC_ALGORITHM = 15
          INVALID_REQUEST = 16
          NESTED_OPERATION_ERRORS = 17
        end
      end

      class KeyValue
        include Beefcake::Message
      end

      class Range
        include Beefcake::Message
      end

      class Setup
        include Beefcake::Message
      end

      class P2POperation
        include Beefcake::Message

        class Operation
          include Beefcake::Message
        end

        class Peer
          include Beefcake::Message
        end
      end

      class GetLog
        include Beefcake::Message

        module Type
          INVALID_TYPE = -1
          UTILIZATIONS = 0
          TEMPERATURES = 1
          CAPACITIES = 2
          CONFIGURATION = 3
          STATISTICS = 4
          MESSAGES = 5
          LIMITS = 6
        end

        class Utilization
          include Beefcake::Message
        end

        class Temperature
          include Beefcake::Message
        end

        class Capacity
          include Beefcake::Message
        end

        class Configuration
          include Beefcake::Message

          class Interface
            include Beefcake::Message
          end
        end

        class Statistics
          include Beefcake::Message
        end

        class Limits
          include Beefcake::Message
        end
      end

      class Security
        include Beefcake::Message

        class ACL
          include Beefcake::Message

          module HMACAlgorithm
            INVALID_HMAC_ALGORITHM = -1
            HmacSHA1 = 1
          end

          module Permission
            INVALID_PERMISSION = -1
            READ = 0
            WRITE = 1
            DELETE = 2
            RANGE = 3
            SETUP = 4
            P2POP = 5
            GETLOG = 7
            SECURITY = 8
          end

          class Scope
            include Beefcake::Message
          end
        end
      end
    end

    class Message

      class Command
        optional :header, Message::Header, 1
        optional :body, Message::Body, 2
        optional :status, Message::Status, 3
      end

      class Header
        optional :clusterVersion, :int64, 1
        optional :identity, :int64, 2
        optional :connectionID, :int64, 3
        optional :sequence, :int64, 4
        optional :ackSequence, :int64, 6
        optional :messageType, Message::MessageType, 7
        optional :timeout, :int64, 9
        optional :earlyExit, :bool, 10
        optional :backgroundScan, :bool, 11
      end

      class Body
        optional :keyValue, Message::KeyValue, 1
        optional :range, Message::Range, 2
        optional :setup, Message::Setup, 3
        optional :p2pOperation, Message::P2POperation, 4
        optional :getLog, Message::GetLog, 6
        optional :security, Message::Security, 7
      end

      class Status
        optional :code, Message::Status::StatusCode, 1
        optional :statusMessage, :string, 2
        optional :detailedMessage, :bytes, 3
      end

      class KeyValue
        optional :newVersion, :bytes, 2
        optional :force, :bool, 8
        optional :key, :bytes, 3
        optional :dbVersion, :bytes, 4
        optional :tag, :bytes, 5
        optional :algorithm, Message::Algorithm, 6
        optional :metadataOnly, :bool, 7
        optional :synchronization, Message::Synchronization, 9
      end

      class Range
        optional :startKey, :bytes, 1
        optional :endKey, :bytes, 2
        optional :startKeyInclusive, :bool, 3
        optional :endKeyInclusive, :bool, 4
        optional :maxReturned, :int32, 5
        optional :reverse, :bool, 6
        repeated :key, :bytes, 8
      end

      class Setup
        optional :newClusterVersion, :int64, 1
        optional :instantSecureErase, :bool, 2
        optional :setPin, :bytes, 3
        optional :pin, :bytes, 4
        optional :firmwareDownload, :bool, 5
      end

      class P2POperation

        class Operation
          optional :key, :bytes, 3
          optional :version, :bytes, 4
          optional :newKey, :bytes, 5
          optional :force, :bool, 6
          optional :status, Message::Status, 7
          optional :p2pop, Message::P2POperation, 8
        end

        class Peer
          optional :hostname, :string, 1
          optional :port, :int32, 2
          optional :tls, :bool, 3
        end
        optional :peer, Message::P2POperation::Peer, 1
        repeated :operation, Message::P2POperation::Operation, 2
        optional :allChildOperationsSucceeded, :bool, 3
      end

      class GetLog

        class Utilization
          optional :name, :string, 1
          optional :value, :float, 2
        end

        class Temperature
          optional :name, :string, 1
          optional :current, :float, 2
          optional :minimum, :float, 3
          optional :maximum, :float, 4
          optional :target, :float, 5
        end

        class Capacity
          optional :nominalCapacityInBytes, :uint64, 4
          optional :portionFull, :float, 5
        end

        class Configuration

          class Interface
            optional :name, :string, 1
            optional :MAC, :bytes, 2
            optional :ipv4Address, :bytes, 3
            optional :ipv6Address, :bytes, 4
          end
          optional :vendor, :string, 5
          optional :model, :string, 6
          optional :serialNumber, :bytes, 7
          optional :worldWideName, :bytes, 14
          optional :version, :string, 8
          optional :compilationDate, :string, 12
          optional :sourceHash, :string, 13
          optional :protocolVersion, :string, 15
          optional :protocolCompilationDate, :string, 16
          optional :protocolSourceHash, :string, 17
          repeated :interface, Message::GetLog::Configuration::Interface, 9
          optional :port, :int32, 10
          optional :tlsPort, :int32, 11
        end

        class Statistics
          optional :messageType, Message::MessageType, 1
          optional :count, :uint64, 4
          optional :bytes, :uint64, 5
        end

        class Limits
          optional :maxKeySize, :uint32, 1
          optional :maxValueSize, :uint32, 2
          optional :maxVersionSize, :uint32, 3
          optional :maxTagSize, :uint32, 4
          optional :maxConnections, :uint32, 5
          optional :maxOutstandingReadRequests, :uint32, 6
          optional :maxOutstandingWriteRequests, :uint32, 7
          optional :maxMessageSize, :uint32, 8
          optional :maxKeyRangeCount, :uint32, 9
        end
        repeated :type, Message::GetLog::Type, 1
        repeated :utilization, Message::GetLog::Utilization, 2
        repeated :temperature, Message::GetLog::Temperature, 3
        optional :capacity, Message::GetLog::Capacity, 4
        optional :configuration, Message::GetLog::Configuration, 5
        repeated :statistics, Message::GetLog::Statistics, 6
        optional :messages, :bytes, 7
        optional :limits, Message::GetLog::Limits, 8
      end

      class Security

        class ACL

          class Scope
            optional :offset, :int64, 1
            optional :value, :bytes, 2
            repeated :permission, Message::Security::ACL::Permission, 3
            optional :TlsRequired, :bool, 4
          end
          optional :identity, :int64, 1
          optional :key, :bytes, 2
          optional :hmacAlgorithm, Message::Security::ACL::HMACAlgorithm, 3
          repeated :scope, Message::Security::ACL::Scope, 4
        end
        repeated :acl, Message::Security::ACL, 2
      end
      optional :command, Message::Command, 1
      optional :hmac, :bytes, 3
    end
  end
end
