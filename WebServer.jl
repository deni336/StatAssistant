module WebServer

    using HTTP
    using Sockets

    export webserver_strings, start_server

    struct webserver_strings
        templates_dir::String
        static_dir::String
    end

    function handle_request(server::webserver_strings, req::HTTP.Request)
        request_path = String(req.target)  # Ensure this is a string type

        # Define a helper function to create and return an HTTP.Response
        function send_response(status::Int, content_type::String, content::String)
            headers = ["Content-Type" => content_type]  # Properly formatted header
            return HTTP.Response(status, headers, content)
        end

        # Handle different request paths
        if request_path == "/"
            html_content = read(joinpath(server.templates_dir, "index.html"), String)
            return send_response(200, "text/html", html_content)
        elseif request_path == "/heroes"
            html_content = read(joinpath(server.templates_dir, "heroes.html"), String)
            return send_response(200, "text/html", html_content)
        elseif request_path == "/items"
            html_content = read(joinpath(server.templates_dir, "items.html"), String)
            return send_response(200, "text/html", html_content)
        elseif request_path == "/games"
            html_content = read(joinpath(server.templates_dir, "games.html"), String)
            return send_response(200, "text/html", html_content)
        elseif request_path == "/style.css"
            css_content = read(joinpath(server.static_dir, "style.css"), String)
            return send_response(200, "text/css", css_content)
        elseif startswith(request_path, "/static/images/")  # Handle images
            image_path = joinpath(server.static_dir, request_path[2:end])  # Remove leading "/"
            if isfile(image_path)
                image_content = read(image_path)
                headers = ["Content-Type" => "image/jpeg"]  # Adjust content type based on image type
                return HTTP.Response(200, headers, image_content)
            else
                return send_response(404, "text/plain", "404 - Image Not Found")
            end
        else
            return send_response(404, "text/plain", "404 - Not Found")
        end
    end

    function start_server(server::webserver_strings, ip, port::Int)
        handler = (req) -> handle_request(server, req)
        HTTP.serve(handler, ip = ip"0.0.0.0", port)
    end

end
