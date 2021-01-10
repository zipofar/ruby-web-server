module Zipserver
  MAX_EOL = 2
  WEB_ROOT = ENV['ROOT_PATH'] || Dir.pwd

  class Server
    def initialize(host, port)
      @host = host
      @port = port
    end

    def run
      @server = TCPServer.new(@host, @port)

      puts "Listening on #{@host}:#{@port}. Press CTRL+C to cancel."

      loop do
        Thread.start(@server.accept) do |client|
          handle_connection(client)
        end
      end
    end

    def shutdown
      @server.shutdown
    end

    private

    def handle_request(request_text, client)
      request  = Zipserver::Request.new(request_text).parse()
      filepath = [WEB_ROOT, request.uri.path].join

      status, headers, body = Zipserver::File.handle(filepath)

      Zipserver::Response.new(status, headers, body).send(client)

      client.shutdown
    end

    def handle_connection(client)
      puts "Getting new client #{client}"
      request_text = ''
      eol_count = 0

      loop do
        buf = client.recv(1)
        request_text += buf

        eol_count += 1 if buf == "\n"

        if eol_count == MAX_EOL
          handle_request(request_text, client)
          break
        end
      end
    rescue => e
      puts "Error: #{e}"
      status = 500
      headers = {}
      body = 'Internal Server Error'

      response = Zipserver::Response.new(status, headers, body).send(client)

      client.close
    end
  end
end

