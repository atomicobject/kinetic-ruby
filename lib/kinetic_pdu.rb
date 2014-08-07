module KineticRuby

  attr_reader :header, :protobuf, :value

  class PDU

    HEADER_LENGTH = 1 + 4 + 4 # version_prefix + protobuf_length + value_length

    def initialize(logger, raw=nil)
      raise "Invalid logger specified!" unless logger
      @logger = logger
      @header = nil
      @protobuf = nil
      @value = nil
      parse(raw) unless raw.nil?
    end

    def complete?
      complete = false
      if @header && @protobuf
        if @header['valueLength'] == 0
          complete = true
        elsif @value && (@value.length >= @header['valueLength'])
          complete = true
        end
      end
      return complete
    end

    def parse(raw)
      if parse_header(raw)
        @logger.log 'PDU Header:'
        @header.each_pair{|k,v| @logger.log "  #{k}: #{v}"}

        if parse_protobuf(raw)
          @logger.log 'PDU Protobuf:'
          @protobuf.to_yaml.each_line{|l| @logger.log('  ' + l)}

          if @header['valueLength'] > 0 && parse_value(raw)
            @logger.log 'PDU Value:'
            @logger.log "  #{@value.to_s}"
          end
        end
      end

      return complete?
    end

    def self.valid_header?(raw)
      (
        !raw.nil? &&
        raw.length >= HEADER_LENGTH &&
        raw[0] == KineticRuby::Proto::VERSION_PREFIX
      )
    end

    def length
      len = 0
      len += HEADER_LENGTH if @header
      len += @header['protobufLength'] if @protobuf
      len += @header['valueLength'] if @value
      return len
    end
    alias size length

    def dump
      return unless complete?
      
      @logger.log('PDU Content', true)

      # Log the header
      @logger.log "  header:\n" +
                  "    version_prefix:  #{@header['versionPrefix']}\n" +
                  "    protobuf_length: #{@header['protobufLength']}\n" +
                  "    value_length:    #{@header['valueLength']}\n"

      # Log the protobuf
      @logger.log "  protobuf:\n" + Proto.to_yaml(@protobuf, '    ')

      # Log the value payload
      @logger.log "  value: (#{value.length} bytes)\n"
      if @logger.level >= Logger::LOG_LEVEL_VERBOSE
        val = @value.dup
        val_string = ''
        while !val.empty?
          val_string += "    #{val.slice!(i,8)}\n"
        end
        @logger.logv val_string
      end
    end

  private
    
    def parse_header(raw)
      if (!raw || raw.length <= HEADER_LENGTH)
        @logger.log "Haven't recevived the full PDU header yet..."
        @logger.log "  header:  raw: #{raw.inspect}" unless (!raw || raw.empty?)
        return nil
      end
      @header = {
        'versionPrefix'  => raw[0],
        'protobufLength' => parse_nbo_int32(raw.byteslice(1..4)),
        'valueLength'    => parse_nbo_int32(raw.byteslice(5..8)),
      }
    end

    def parse_protobuf(raw)
      min_length = (HEADER_LENGTH + @header['protobufLength'])
      return nil unless (@header && raw.length >= min_length)
      start_idx = HEADER_LENGTH
      end_idx = HEADER_LENGTH + min_length - 1
      protobuf = raw.byteslice(start_idx, end_idx)
      @protobuf = Seagate::Kinetic::Message.decode(protobuf)
    end
    
    def parse_value(raw)
      preamble_length = HEADER_LENGTH + @header['protobufLength']
      min_length = preamble_length + 1
      full_length = preamble_length + @header['valueLength']
      return nil unless (@header && @protobuf && raw.length >= min_length)
      end_idx = preamble_length + @header['protobufLength'] - 1
      @value = raw.byteslice(preamble_length, end_idx)
    end

    def parse_nbo_int32(data)
      raise "Not enough data to parse NBO integer!" unless data.length >= 4
      val = 0
      data.each_byte do |byte|
        val <<= 8
        val += byte
      end
      return val
    end

  end

end
