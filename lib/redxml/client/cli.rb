require 'redxml/client'
require 'singleton'
require 'optparse'

module RedXML
  class Client
    class CLI
      include Singleton unless $TESTING

      attr_accessor :options

      def parse(args = ARGV)
        @options = parse_options(args)
      end

      def run
        client = RedXML::Client.new(options)
        repl = RedXML::Client::REPL.new(client)
        repl.repl
      end

      private

      def parse_options(argv)
        opts = {}

        parser = OptionParser.new do |o|
          o.banner = 'redxml-client [options]'

          o.on '-s', '--scheme SCHEME', 'tcp/unix' do |arg|
            opts[:scheme] = arg
          end

          o.on '-h', '--host HOST', 'Host to connect to' do |arg|
            opts[:host] = arg
          end

          o.on '-p', '--port INT', 'Port to connect' do |arg|
            opts[:port] = arg.to_i
          end

          o.on '-u', '--unix INT', 'Unix socket to connect' do |arg|
            opts[:port] = arg.to_i
          end

          o.on_tail '-h', '--help', 'Show help' do
            die 1
          end
        end
        parser.parse!(argv)

        opts
      end
    end
  end
end
