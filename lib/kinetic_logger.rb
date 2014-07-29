module KineticRuby
  class Logger
    def initialize(logging_level=LOG_LEVEL_INFO, stream=$stdout)
      set_log_level(logging_level)
      @stream = stream
    end

    LOG_LEVELS = [
      LOG_LEVEL_NONE = 0,
      LOG_LEVEL_ERROR = 1,
      LOG_LEVEL_INFO = 2,
      LOG_LEVEL_VERBOSE = 3,
    ]

    def set_log_level(level)
      if !LOG_LEVELS.include? level
        raise "\nInvalid LOG_LEVEL specified!\nValid levels:\n\t" +
          LOG_LEVELS.map{|l|"#{self.class}::#{l}"}.join("\n\t") + "\n\n"
      end
      @level = level
    end

    def log_info(msg='')
      log_message(msg) if @level >= LOG_LEVEL_INFO
    end
    alias log log_info

    def log_err(msg='')
      log_message(msg, $stderr) if @level >= LOG_LEVEL_ERROR
    end

    def log_verbose(msg='')
      log_message(msg) if @level >= LOG_LEVEL_VERBOSE
    end

    def log_message(msg='')
      $stderr.flush
      @stream.flush
      @stream.puts msg
      @stream.flush
    end
  end
end
