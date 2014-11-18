require 'redxml/client/connection'
require 'redxml/client/repl'
require 'redxml/client/dsl'
require 'redxml/client/version'

module RedXML
  class Client
    include DSL

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

    def close
      connection.close unless closed?
    end

    def closed?
      connection.closed?
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
