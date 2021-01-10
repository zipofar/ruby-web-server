module Zipserver
  module File
    DEFAULT_CONTENT_TYPE = 'application/octet-stream'
    CONTENT_TYPE_MAPPING = {
      'html' => 'text/html',
      'txt' => 'text/plain',
      'png' => 'image/png',
      'jpg' => 'image/jpeg'
    }.freeze

    def self.handle(path)
      available = begin
        ::File.file?(path) && ::File.readable?(path)
      rescue SystemCallError
        false
      end

      if available
        build(path)
      else
        [404, {}, '']
      end
    end

    def self.build(path)
      headers = {}
      headers['Content-Type'] = content_type(path)
      headers['Content-Length'] = filesize(path).to_s
      status = 200
      body = ::File.readlines(path, 'rb').join

      [status, headers, body]
    end

    def self.content_type(path)
      ext = ::File.extname(path).gsub(/\./, '')
      CONTENT_TYPE_MAPPING[ext] || DEFAULT_CONTENT_TYPE
    end

    def self.filesize(path)
      #   We check via File::size? whether this file provides size info
      #   via stat (e.g. /proc files often don't), otherwise we have to
      #   figure it out by reading the whole file into memory.
      ::File.size?(path) || ::File.read(path).bytesize
    end
  end
end

