require 'redxml/client/connection'
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
      client.connect
      if block_given?
        begin
          block.call(client)
        ensure
          client.disconnect
        end
      end
      client
    end

    attr_reader :connection

    def initialize(options)
      @options = parse_options(options = {})
    end

    def execute(xquery)
      connection.write(:execute, xquery)
    end

    def connect
      fail 'Already connected' if @connection
      @connection = establish_connection
    end

    def disconnect
      connection.disconnect if connection
      @connection = nil
    end

    def disconnected?
      connection.nil?
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
      connection = RedXML::Client::Connection.new(@options)
      connection.connect
      connection
    end
  end
end
