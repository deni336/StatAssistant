using HTTP

function handle_request(http::HTTP.Stream)
    request_path = http.message.target

    if request_path == "/"
        HTTP.setstatus(http, 200)
        HTTP.setheader(http, "Content-Type" => "text/html")
        HTTP.startwrite(http)
        html_content = read("templates/index.html", String)
        write(http, html_content)
    elseif request_path == "/heroes"
        HTTP.setstatus(http, 200)
        HTTP.setheader(http, "Content-Type" => "text/html")
        HTTP.startwrite(http)
        html_content = read("templates/heroes.html", String)
        write(http, html_content)
    elseif request_path == "/items"
        HTTP.setstatus(http, 200)
        HTTP.setheader(http, "Content-Type" => "text/html")
        HTTP.startwrite(http)
        html_content = read("templates/items.html", String)
        write(http, html_content)
    elseif request_path == "/games"
        HTTP.setstatus(http, 200)
        HTTP.setheader(http, "Content-Type" => "text/html")
        HTTP.startwrite(http)
        html_content = read("templates/games.html", String)
        write(http, html_content)
    elseif request_path == "/style.css"
        HTTP.setstatus(http, 200)
        HTTP.setheader(http, "Content-Type" => "text/css")
        HTTP.startwrite(http)
        css_content = read("static/style.css", String)
        write(http, css_content)
    elseif startswith(request_path, "/static/images/")  # Handle images
        image_path = request_path[2:end]  # Remove the leading "/"
        if isfile(image_path)
            HTTP.setstatus(http, 200)
            HTTP.setheader(http, "Content-Type" => "image/jpg")  # Adjust content type based on image type
            HTTP.startwrite(http)
            image_content = read(image_path)
            write(http, image_content)
        else
            HTTP.setstatus(http, 404)
            HTTP.startwrite(http)
            write(http, "404 - Image Not Found")
        end
    else
        HTTP.setstatus(http, 404)
        HTTP.startwrite(http)
        write(http, "404 - Not Found")
    end
end

HTTP.listen() do http::HTTP.Stream
    handle_request(http)
end
