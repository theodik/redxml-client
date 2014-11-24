module RedXML
  class Client
    module DSL
      def ping
        connection.send(:ping)
      end

      def server_version
        connection.server_version
      end

      def begin
        connection.send(:begin)
      end

      def commit
        connection.send(:commit)
      end

      def rollback
        connection.send(:rollback)
      end

      def execute(xquery)
        check_environment

        param = [@environment, @collection, xquery].join("\1")
        connection.send(:execute, param)
      end

      def save_document(file_name)
        check_environment

        file_name = File.expand_path(file_name)
        document_name = File.basename(file_name)
        document = File.open(file_name, &:read)
        param = [@environment, @collection, document_name, document].join("\1")

        connection.send(:save_document, param)
      end

      def load_document(document_name, file_name = nil)
        check_environment

        param = [@environment, @collection, document_name].join("\1")
        document = connection.send(:load_document, param)
        if file_name
          file_name = File.expand_path(file_name)
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
