require 'socket'
require './lib/response'
require './lib/request'
require './lib/file'

MAX_EOL = 2
WEB_ROOT = './public'

socket = TCPServer.new(ENV['HOST'], ENV['PORT'])

def handle_request(request_text, client)
  request  = ZipServer::Request.new(request_text).parse()
  filepath = [WEB_ROOT, request.uri.path].join

  status, headers, body = ZipServer::File.handle(filepath)

  ZipServer::Response.new(status, headers, body).send(client)

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

  response = ZipServer::Response.new(status, headers, body).send(client)

  client.close
end

puts "Listening on #{ENV['HOST']}:#{ENV['PORT']}. Press CTRL+C to cancel."

loop do
  Thread.start(socket.accept) do |client|
    handle_connection(client)
  end
end

