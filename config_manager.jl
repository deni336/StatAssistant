module ConfigManager
    using TOML
    using FilePathsBase
    using Dates

    mutable struct config_struct
        config_file::String
        config::Dict{String, Any}
    end

    function setup_config(config_file::String="src/config/config.toml")
        config = Dict{String, Any}()
        if isfile(config_file)
            config = TOML.parsefile(config_file)
        else
            # If config file doesn't exist, create a default one
            config = Dict(
                "WebServer" => Dict(
                    "port" => "8000",
                    "address" => "localhost",
                    "uploadfolder" => "stations/"
                ),
                "Logging" => Dict(
                    "path" => "logs/",
                    "loglevel" => "INFO"
                )
            )
            TOML.print(config_file, config)
        end

        return config_struct(config_file, config)
    end

    function get(config_manager::config_struct, section::String, option::String, fallback::Any=nothing)
        try
            if haskey(config_manager.config, section) && haskey(config_manager.config[section], option)
                return config_manager.config[section][option]
            else
                return fallback
            end
        catch e
            println("Error getting configuration value: $e")
            return fallback
        end
    end

    function set!(config_manager::config_struct, section::String, option::String, value::Any)
        if !haskey(config_manager.config, section)
            config_manager.config[section] = Dict()
        end
        config_manager.config[section][option] = value
        TOML.print(config_manager.config_file, config_manager.config)
    end
end
