require 'redxml/client/connection'
require 'redxml/client/repl'
require 'redxml/client/version'

module RedXML
  class Client
    DEFAULTS = {
      url: -> { ENV['REDXML_URL'] },
      scheme: 'tcp',
      host: 'localhost',
      port: '33965',
      unix: '/var/run/redxml/redxml.sock',
      db: 0
    }.freeze

    def self.connect(options, &block)
      client = new(options)
      if block_given?
        begin
          block.call(client)
        ensure
          client.close
        end
      end
      client
    end

    attr_reader :connection

    def initialize(options = {})
      @options = parse_options(options)
      @connection = establish_connection
    end

    def execute(env, col, xquery)
      param = [env, col, xquery].join("\1")
      connection.send(:execute, param)
    end

    def ping
      connection.send(:ping)
    end

    def close
      connection.close unless closed?
    end

    def closed?
      connection.closed?
    end

    def server_version
      connection.server_version
    end

    private

    def parse_options(options)
      options = DEFAULTS.dup.merge(options)
      options.keys.each do |key|
        options[key] = options[key].call if options[key].respond_to? :call
      end
      options
    end

    def establish_connection
      # driver_class = RedXML::Client::Connection.drivers[schema]
      # driver = driver_class.new
      RedXML::Client::Connection.new(@options)
    end
  end
end
