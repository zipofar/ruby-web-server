require 'zipserver'

module Rack
  module Handler
    class Zipserver
      def self.run(_app, **options)
        environment  = ENV['RACK_ENV'] || 'development'
        default_host = environment == 'development' ? 'localhost' : nil

        if !options[:BindAddress] || options[:Host]
          options[:BindAddress] = options.delete(:Host) || default_host
        end
        options[:Port] ||= 8080

        @server = ::Zipserver::Server.new(options[:Host], options[:Port])
        @server.run
      end

      def self.shutdown
        if @server
          @server.shutdown
          @server = nil
        end
      end

      def self.valid_options
        environment  = ENV['RACK_ENV'] || 'development'
        default_host = environment == 'development' ? 'localhost' : '0.0.0.0'

        {
          "Host=HOST" => "Hostname to listen on (default: #{default_host})",
          "Port=PORT" => "Port to listen on (default: 8080)",
        }
      end
    end

    register 'zipserver', 'Rack::Handler::Zipserver'
  end
end

