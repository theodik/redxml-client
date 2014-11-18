require 'redxml/protocol'

module RedXML
  class Client
    class ServerError < RuntimeError
    end

    class Connection
      @drivers = {}

      def self.drivers
        @drivers
      end

      attr_reader :driver, :server_version

      def initialize(options)
        @options = options.dup

        scheme = @options.delete(:scheme)
        @driver = find_driver(scheme).new(@options)

        read_server_version
      end

      def send(command, param = nil)
        packet = RedXML::Protocol::PacketBuilder.new
          .command(command)
          .param(param)
          .build

        driver.write(packet)

        packet = driver.read
        fail ServerError, packet.param if packet.error?
        packet.param
      end

      def close
        @driver.close
      end

      def closed?
        @driver.closed?
      end

      def address
        driver.address
      end

      private

      def find_driver(schema)
        driver_class = self.class.drivers[schema]
        fail ArgumentError, "Schema '#{schema}' " \
          'is not supported' unless driver_class
        driver_class
      end

      def read_server_version
        packet = driver.read
        fail 'Server didnt send hello' unless packet
        fail 'Server sent wrong data' if packet.command != :hello
        @server_version = packet.param
      end
    end

    module DriverMixin
      def write(packet)
        data = packet.is_a?(String) ? data : packet.data
        socket.write(data)
      end

      def read
        RedXML::Protocol.read_packet(socket)
      end

      def closed?
        socket.closed?
      end

      def close
        socket.close
      end
    end

    class TCPDriver
      include DriverMixin
      attr_reader :socket

      def initialize(options)
        @socket = ::TCPSocket.new(options[:host], options[:port])
      end

      def address
        @socket.peeraddr[1..2].reverse.join(':')
      end
    end
    Connection.drivers['tcp'] = TCPDriver

    class DummyDriver
      include DriverMixin

      def initialize(*)
      end

      def socket
        StringIO.new
      end

      def closed?
        false
      end

      def close
      end

      def address
        'dummy'
      end
    end
    Connection.drivers['dummy'] = DummyDriver
  end
end
