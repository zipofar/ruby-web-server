require 'uri'

module Zipserver
  class Request
    attr_reader :method, :path, :version, :headers, :body, :uri

    def initialize(request = '')
      @raw_request = request
    end

    def parse
      @method, @path, @version = @raw_request.lines[0].split
      @uri = URI(@path)

      @headers = {}
      @body = {}

      mode = :headers
      @raw_request.lines[1..-1].each do |line|
        return mode = :body if line == "\r\n"

        if mode == :headers
          header, value = line.split
          add_header(header, value)
        else
          add_body(line)
        end
      end

      self
    end

    private

    def add_body(line)
      @body += line
    end

    def add_header(header, value)
      header = normalize(header)
      @headers[header] = value
    end

    def normalize(header)
      header.gsub(":", "").downcase.to_sym
    end
  end
end

