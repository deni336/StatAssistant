using HTTP

include("global_logger.jl", "config_manager.jl")


struct WebServer
    templates_dir::String
    static_dir::String
end

function handle_request(server::WebServer, http::HTTP.Stream)
    request_path = http.message.target

    # Define a helper function to set headers and send response content
    function send_response(http, status::Int, content_type::String, content::String)
        HTTP.setstatus(http, status)
        HTTP.setheader(http, "Content-Type" => content_type)
        HTTP.startwrite(http)
        write(http, content)
    end

    if request_path == "/"
        html_content = read(joinpath(server.templates_dir, "index.html"), String)
        send_response(http, 200, "text/html", html_content)
    elseif request_path == "/heroes"
        html_content = read(joinpath(server.templates_dir, "heroes.html"), String)
        send_response(http, 200, "text/html", html_content)
    elseif request_path == "/items"
        html_content = read(joinpath(server.templates_dir, "items.html"), String)
        send_response(http, 200, "text/html", html_content)
    elseif request_path == "/games"
        html_content = read(joinpath(server.templates_dir, "games.html"), String)
        send_response(http, 200, "text/html", html_content)
    elseif request_path == "/style.css"
        css_content = read(joinpath(server.static_dir, "style.css"), String)
        send_response(http, 200, "text/css", css_content)
    elseif startswith(request_path, "/static/images/")  # Handle images
        image_path = joinpath(server.static_dir, request_path[2:end])  # Remove leading "/"
        if isfile(image_path)
            image_content = read(image_path)
            HTTP.setstatus(http, 200)
            HTTP.setheader(http, "Content-Type" => "image/jpg")  # Adjust content type based on image type
            HTTP.startwrite(http)
            write(http, image_content)
        else
            send_response(http, 404, "text/plain", "404 - Image Not Found")
        end
    else
        send_response(http, 404, "text/plain", "404 - Not Found")
    end
end

function start_server(server::WebServer, port::Int)
    HTTP.listen(; host = "0.0.0.0", port = port) do http::HTTP.Stream
        handle_request(server, http)
    end
end