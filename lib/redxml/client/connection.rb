# require 'redxml/client/driver'

module RedXML
  class Client
    class Connection
      @@drivers = {}

      def self.drivers
        @@drivers
      end

      attr_reader :driver

      def initialize(options)
        @options = options
        @driver = find_driver(options.delete(:schema))
      end

      def connect
        @driver.connect(@options)
      end

      def close
        @driver.close
      end

      private

      def find_driver(schema)
        driver_klass = self.class.drivers[schema]
        driver_klass.new(@options)
      end
    end

    module DriverMixin
      def connect
        @socket.connect
      end
    end

    class TCPDriver
      include DriverMixin
      attr_reader :socket

      def initialize(options)
        @socket = ::TCPSocket.new(options[:host], options[:port])
      end
    end
    Connection.drivers['tcp'] = TCPDriver
  end
end
