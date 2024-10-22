include("webserver.jl")
import .WebServer

function main()
    server = WebServer.webserver_strings("templates", "static")
    println("Starting server on http://localhost:8080...")
    WebServer.start_server(server,"127.0.0.1", 9006)
end

main()
