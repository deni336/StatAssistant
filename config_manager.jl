using TOML
using FilePathsBase
using Dates

mutable struct ConfigManager
    config_file::String
    config::Dict{String, Any}
end

function ConfigManager(config_file::String="src/config/config.toml")
    config = Dict{String, Any}()
    if isfile(config_file)
        config = TOML.parsefile(config_file)
    else
        # If config file doesn't exist, create a default one
        config = Dict(
            "Library" => Dict(
                "gmappath" => "stations/gmap-stations.txt",
                "dbfilepath" => "stations/site-info.db",
                "dbfilepathall" => "stations/site-info-all.db",
                "lastupdate" => "0.0"
            ),
            "WebServer" => Dict(
                "port" => "8000",
                "address" => "localhost",
                "uploadfolder" => "stations/"
            ),
            "Logging" => Dict(
                "path" => "logs/",
                "loglevel" => "INFO"
            ),
            "AlertSettings" => Dict(
                "alertclasses" => "",
                "emails" => "",
                "phonenumbers" => "",
                "smtpserver" => "smtp.gmail.com",
                "smtpport" => "587"
            ),
            "ClassLabels" => Dict()
        )
        TOML.print(config_file, config)
    end

    return ConfigManager(config_file, config)
end

function get(config_manager::ConfigManager, section::String, option::String, fallback::Any=nothing)
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

function set!(config_manager::ConfigManager, section::String, option::String, value::Any)
    if !haskey(config_manager.config, section)
        config_manager.config[section] = Dict()
    end
    config_manager.config[section][option] = value
    TOML.print(config_manager.config_file, config_manager.config)
end

function get_alert_recipients(config_manager::ConfigManager, recipient_type::String)
    recipients_str = get(config_manager, "AlertSettings", recipient_type, "")
    recipients = Dict{String, Bool}()
    if !isempty(recipients_str)
        for recipient in split(recipients_str, ',')
            if occursin(":", recipient)
                contact, enabled = split(recipient, ':')
                recipients[strip(contact)] = strip(enabled) == "true"
            end
        end
    end
    return recipients
end

function set_alert_recipients!(config_manager::ConfigManager, recipient_type::String, recipients::Dict{String, Bool})
    recipients_str = join([string(contact, ":", lowercase(string(enabled))) for (contact, enabled) in recipients], ",")
    set!(config_manager, "AlertSettings", recipient_type, recipients_str)
end

function get_class_labels(config_manager::ConfigManager)
    if haskey(config_manager.config, "ClassLabels")
        return Dict{String, Int}(key => parse(Int, value) for (key, value) in config_manager.config["ClassLabels"])
    else
        return Dict{String, Int}()
    end
end

function add_class_label!(config_manager::ConfigManager, class_name::String, label::Int)
    if !haskey(config_manager.config, "ClassLabels")
        config_manager.config["ClassLabels"] = Dict()
    end
    config_manager.config["ClassLabels"][class_name] = string(label)
    TOML.print(config_manager.config_file, config_manager.config)
end
