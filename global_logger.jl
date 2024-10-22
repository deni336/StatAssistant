module GlobalLogger
    using Logging
    using Dates
    using FilePathsBase
    using Base.Threads

    mutable struct logger_struct
        loggers::Dict{String, Logging.ConsoleLogger}
        config::ConfigManager
        lock::ReentrantLock
    end

    function setup_logger(config::logger_struct)
        return logger_struct(Dict(), config, ReentrantLock())
    end

    function get_logger(global_logger::logger_struct, name::String)
        # Fetch configuration values
        log_dir = get(global_logger.config, "Logging", "path")
        log_level_str = get(global_logger.config, "Logging", "loglevel")

        # Convert log level string to Symbol
        log_level = Symbol(log_level_str)

        # Return the logger if it already exists
        if haskey(global_logger.loggers, name)
            return global_logger.loggers[name]
        end

        # Ensure thread safety using ReentrantLock
        lock(global_logger.lock) do
            # Double check to avoid race condition
            if haskey(global_logger.loggers, name)
                return global_logger.loggers[name]
            end

            # Create log directory if it doesn't exist
            if !isdir(log_dir)
                mkpath(log_dir)
            end

            # Create a log file with the current date
            current_date = Dates.format(now(), "yyyy-mm-dd")
            log_file = joinpath(log_dir, "$current_date.log")

            # Define a custom logger that writes to a file
            open(log_file, "a") do io
                logger = ConsoleLogger(io, level=log_level)
                global_logger.loggers[name] = logger
            end
        end

        return global_logger.loggers[name]
    end
end