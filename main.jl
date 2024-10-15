include("WebServer.jl")

struct Main
    # Main function to run the server
    function main()
        server = WebServer("templates", "static")
        println("Starting server on http://localhost:8080...")
        start_server(server, 8080)
    end

    main()
end