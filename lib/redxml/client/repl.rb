require 'readline'

module RedXML
  class Client
    class REPL
      attr_reader :client, :input, :output

      def initialize(client)
        @client = client
        @stty   = `stty -g`.chomp
        load_history
      end

      def repl
        write_header
        catch :quit do
          loop do
            catch :next do
              line = prompt
              command, param = parse line
              write execute(command, param)
            end
          end
        end
        client.close
        write "Bye."
        write_history
      end

      private

      def load_history
        hist_file = File.expand_path('~/.redxml-hist')
        return unless File.exists? hist_file
        File.open(hist_file).each_line.map(&:chomp).reject(&:empty?).each do |line|
          Readline::HISTORY << line
        end
      end

      def write_history
        hist_file = File.expand_path('~/.redxml-hist')
        File.open(hist_file, 'w') do |f|
          f.write Readline::HISTORY.to_a.uniq.join("\n")
        end
      end

      def write_header
        write <<-EOD.gsub(/^\s+/,''), ''
          Connected to #{client.connection.address} (#{client.server_version})
        EOD
      end

      def prompt
        line = Readline.readline('redxml> ', true)
        write('') and throw :quit if line.nil?
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
        method = client.method(command)
        params = param.split(/\s/, method.arity)
        method.call(*params)
      rescue RedXML::Client::ServerError => e
        "ERROR: #{e}"
      end

      def write(obj, eol = "\n")
        printf("%s%s", obj.to_s, eol)
        true
      end
    end
  end
end
