require 'readline'

module RedXML
  class Client
    class REPL
      attr_reader :client, :input, :output

      def initialize(client)
        @client = client
        @stty   = `stty -g`.chomp
      end

      def repl
        write_header
        catch :quit do
          loop do
            catch :next do
              line = prompt
              command, param = parse line
              response = execute command, param
              write_response response
            end
          end
        end
        client.close
        write "Bye."
      end

      private

      def write_header
        write <<-EOD.gsub(/^\s+/,''), ''
          Connected to #{client.connection.address} (#{client.server_version})
        EOD
      end

      def prompt
        line = Readline.readline('redxml> ', true)
        write '' and throw :quit if line.nil?
        throw :quit if line.strip =~ /^quit/
        throw :next if line.strip.empty?
        line
      rescue Interrupt
        system('stty', @stty)
        write ''
        throw :next
      end

      def parse(line)
        cmd, param = line.strip.split(nil, 2)
        cmd = cmd.to_sym
        unless client.respond_to? cmd
          cmd   = :execute
          param = line.chomp
        end
        [cmd, param]
      end

      def execute(command, param)
        args = [command, param].compact
        client.public_send(*args)
      end

      def write_response(response)
        write("\n") and return if response.nil?
        write response and return unless response.is_a? RedXML::Protocol::Packet

        case response.command
        when :execute
          write response.param
        when :ping
          write "\tpong"
        else
          write "  #{response.command}: #{response.param}"
        end
      end

      def write(obj, eol = "\n")
        $stdin.write(obj.to_s + eol)
      end
    end
  end
end
