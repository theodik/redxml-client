require 'tempfile'
require 'spec_helper'

RSpec.describe RedXML::Client do
  let(:options) { { scheme: 'tcp', host: 'localhost', port: 33965 } }
  before do
    conn = class_double('RedXML::Client::Connection').as_stubbed_const
    @conn_double = double('connection')
    allow(conn).to receive(:new).with(any_args).and_return(@conn_double)
  end
  subject { RedXML::Client.connect(options) }

  describe '#server_version' do
    it 'returns connected server version' do
      expect(@conn_double).to receive(:server_version).and_return('Test-0.0.1')
      expect(subject.server_version).to eq 'Test-0.0.1'
    end
  end

  describe '#execute' do
    it 'returns result' do
      expect(@conn_double).to receive(:send).with(:execute, "test_env\1test_col\1/.")
      subject.execute('test_env', 'test_col', '/.')
    end
  end

  describe '#ping' do
    it 'pings' do
      expect(@conn_double).to receive(:send).with(:ping)
      subject.ping
    end
  end

  describe '#save_document' do
    it 'loads file' do
      file = Tempfile.new(['test_document', '.xml'])
      file.write '<xml>test</xml>'
      file.close

      document_name = File.basename(file.path)
      expect(@conn_double).to receive(:send).with(:save_document, "test_env\1test_col\1#{document_name}\1<xml>test</xml>")

      subject.save_document('test_env', 'test_col', file.path)

      file.unlink
    end
  end

  describe '#load_document' do
    it 'saves document to file' do
      file_name = Dir::Tmpname.make_tmpname(['/tmp/document', '.xml'], nil)
      document_name = File.basename(file_name)

      expect(@conn_double).to receive(:send).with(:load_document, "test_env\1test_col\1#{document_name}") { '<xml>test</xml>' }

      subject.load_document('test_env', 'test_col', document_name, file_name)

      document = File.open(file_name, &:read)
      expect(document).to eq "<xml>test</xml>\n"

      File.unlink(file_name)
    end

    it 'returns document' do
      document_name = 'test_document.xml'
      expect(@conn_double).to receive(:send).with(:load_document, "test_env\1test_col\1#{document_name}") { '<xml>test</xml>' }

      document = subject.load_document('test_env', 'test_col', document_name)

      expect(document).to eq '<xml>test</xml>'
    end
  end
end
