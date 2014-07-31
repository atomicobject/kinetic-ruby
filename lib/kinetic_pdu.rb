module KineticRuby

  attr_reader :header, :protobuf, :value

  class PDU

    def initialize(logger, raw=nil)
      raise "Invalid logger specified!" unless logger
      @logger = logger
      parse(raw)
    end

    def parse(raw)
      @header = parse_header(raw)
      @protobuf = parse_protobuf(raw) if @header
      @value = parse_value(raw) if (@header && @protobuf)
      return (@header && @protobuf && @value)
    end

    def length
      len = 0
      len += HEADER_LENGTH if @header
      len += @header[:protobuf_length] if @protobuf
      len += @header[:value_length] if @value
      return len
    end
    alias size length

  private

    HEADER_LENGTH = 1 + 4 + 4 # version_prefix + protobuf_length + value_length
    
    def parse_header(raw)
      return nil unless (raw && raw.length <= HEADER_LENGTH)
      {
        version_prefix: raw[0],
        protobuf_length: parse_nbo_int32(raw.byteslice(1..4)),
        value_length: parse_nbo_int32(raw.byteslice(5..9))
      }
    end

    def parse_protobuf(raw)
      min_length = (HEADER_LENGTH + @header[:protobuf_length])
      return nil unless (@header && raw.length >= min_length)
      start_idx = HEADER_LENGTH
      end_idx = HEADER_LENGTH + min_length - 1
      protobuf = raw.byteslice(start_idx, end_idx)
      Seagate::Kinetic::Message.decode(protobuf)
    end
    
    def parse_value(raw)
      min_length = (HEADER_LENGTH + @header[:protobuf_length] + @header[:value_length])
      return nil unless (@header && @protobuf && raw.length >= min_length)
      start_idx = HEADER_LENGTH + @header[:protobuf_length]
      end_idx = start_idx + @header[:protobuf_length] - 1
      @value = raw.byteslice(start_idx, end_idx)
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
