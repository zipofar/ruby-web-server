module Zipserver
  SERVER_NAME = 'Zipserver'

  class Response
    def initialize(status, headers = {}, body = '')
      @status = status
      @body = body
      @headers = headers
    end

    def headers
      "HTTP/1.1 #{@status}\r\n" +
      "Server: #{SERVER_NAME}\r\n" +
      build_headers().join("\r\n") +
      "\r\n\r\n"
    end

    def body
      return '' if @body.nil? || @body.empty?
      return "#{@body}\r\n"
    end

    def send(client)
      response = headers + body
      client.write(response)
    end

    private

    def build_headers
      @headers.map { |k, v| "#{k}: #{v}" }
    end
  end
end

