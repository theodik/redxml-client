module RedXML
  class Client
    module DSL
      def execute(env, col, xquery)
        param = [env, col, xquery].join("\1")
        connection.send(:execute, param)
      end

      def ping
        connection.send(:ping)
      end

      def server_version
        connection.server_version
      end

      def save_document(env, col, file_name)
        document_name = File.basename(file_name)
        document = File.open(file_name, &:read)
        param = [env, col, document_name, document].join("\1")

        connection.send(:save_document, param)
      end

      def load_document(env, col, document_name, file_name = nil)
        param = [env, col, document_name].join("\1")

        document = connection.send(:load_document, param)
        if file_name
          File.open(file_name, 'w') do |f|
            f.puts document
          end
          true
        else
          document
        end
      end
    end
  end
end
