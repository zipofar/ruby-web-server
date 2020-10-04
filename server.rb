# ab -n 10000 -c 100 -p ./section_one/ostechnix.txt localhost:1234/
# head -c 100000 /dev/urandom > section_one/ostechnix_big.txt

require 'socket'
require './lib/response'
require './lib/request'
MAX_EOL = 2

CONTENT_TYPE_MAPPING = {
  'html' => 'text/html',
  'txt' => 'text/plain',
  'png' => 'image/png',
  'jpg' => 'image/jpeg'
}.freeze

DEFAULT_CONTENT_TYPE = 'application/octet-stream'
WEB_ROOT = './public'

socket = TCPServer.new(ENV['HOST'], ENV['PORT'])

def get_file(filepath)
  error = if !File.exist?(filepath) || File.directory?(filepath)
    { code: 404 }
  elsif !File.readable?(filepath)
    { code: 403 }
  else
    nil
  end

  return [error, nil] if !error.nil?

  file_data = File.readlines(filepath, 'rb').join
  return [error, file_data]
end

def get_content_type(filepath)
  ext = File.extname(filepath)[1..-1]
  CONTENT_TYPE_MAPPING[ext] || DEFAULT_CONTENT_TYPE
end

def build_header(key, value)
  "#{key}: #{value}"
end

def handle_request(request_text, client)
  request  = Request.new(request_text)
  filepath = [WEB_ROOT, request.uri.path].join
  content_type = get_content_type(filepath)
  header_content_type = build_header('Content-Type', content_type)
  error, content = get_file(filepath)

  response = if error.nil?
    Response.new(code: 200, data: content, headers: [header_content_type])
  else
    Response.new(code: error[:code])
  end

  response.send(client)

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

    # sleep 1
  end
rescue => e
  puts "Error: #{e}"

  response = Response.new(code: 500, data: "Internal Server Error")
  response.send(client)

  client.close
end

puts "Listening on #{ENV['HOST']}:#{ENV['PORT']}. Press CTRL+C to cancel."

loop do
  Thread.start(socket.accept) do |client|
    handle_connection(client)
  end
end

