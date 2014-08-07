require 'date'

module KineticRuby

  class Logger

    LOG_LEVELS = [
      LOG_LEVEL_NONE = 0,
      LOG_LEVEL_ERROR = 1,
      LOG_LEVEL_INFO = 2,
      LOG_LEVEL_VERBOSE = 3,
    ]

    def initialize(log_level=LOG_LEVEL_INFO, stream=$stdout, enable_timestamp=true)
      set_level log_level
      @stream = stream
      @prefix = ''
      @timestamp_enabled = enable_timestamp
    end

    def level=(log_level)
      set_level(log_level)
    end

    def level
      @level.dup
    end

    def enable_timestamp(enable=true)
      @timestamp_enabled = enable
    end

    def timestamp_enabled
      @timestamp_enabled
    end

    def prefix=(msg)
      @prefix = msg if msg
    end

    def prefix
      @prefix.dup if @prefix
    end

    def log_info(msg='', banner=nil)
      log_message(msg, banner) if @level >= LOG_LEVEL_INFO
    end
    alias logi log_info
    alias log log_info

    def log_err(msg='', banner=nil)
      log_message(msg, banner) if @level >= LOG_LEVEL_ERROR
    end
    alias loge log_err

    def log_verbose(msg='', banner=nil)
      log_message(msg, banner) if @level >= LOG_LEVEL_VERBOSE
    end
    alias logv log_verbose

    def log_exception(exception, desc=nil, level=LOG_LEVEL_ERROR)
      log_err(desc) if (desc && !desc.empty?)
      log_err "Exception #{exception.class} '#{exception.message}' occured at:"
      exception.backtrace.each do |l|
        log_err "  #{l}"
      end
    end

  private

    def set_level(log_level)
      if !LOG_LEVELS.include? log_level
        raise "\nInvalid LOG_LEVEL specified: #{log_level}\nValid levels:\n  " +
          LOG_LEVELS.map{|l|"#{self.class}::#{l}"}.join("\n  ") + "\n\n"
      end
      @level = log_level
    end

    def log_message(msg, banner)
      now = '[' + DateTime.now.to_s + '] '
      timestamp = @timestamp_enabled ? now : '[N/A]'
      @stream.puts(timestamp + @prefix + msg) if (msg)
      @stream.puts(timestamp + @prefix + ('-'*40)) if (banner && msg)
      @stream.flush
    end

  end
end
