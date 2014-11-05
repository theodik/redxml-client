require 'spec_helper'

RSpec.describe RedXML::Client do
  let(:options) { { scheme: 'tcp', host: 'localhost', port: 6380, db: 0 } }


  before do
    conn = class_double('RedXML::Client::Connection').as_stubbed_const
    @conn_double = double('connection')
    expect(@conn_double).to receive(:connect).with(no_args)
    allow(conn).to receive(:new).with(any_args).and_return(@conn_double)
  end

  describe '.connect' do
    it 'connects to server' do
      client = RedXML::Client.new(options)
      expect(client.connect).to be_truthy
    end
    it 'returns client' do
      client = RedXML::Client.connect(options)
      expect(client).to be_a RedXML::Client
    end

    it 'accepts block with client as an argument' do
      allow(@conn_double).to receive(:connect).with(no_args)
      expect(@conn_double).to receive(:disconnect).with(no_args)
      RedXML::Client.connect(options) do |client|
        expect(client).to be_a RedXML::Client
      end
    end

    it 'connects and disconnect' do
      expect(@conn_double).to receive(:disconnect).with(no_args)
      client = nil
      RedXML::Client.connect(options) do |c|
        client = c
        expect(client).to_not be_disconnected
      end
      expect(client).to be_disconnected
    end
  end

  describe '#execute' do
    subject { RedXML::Client.connect(options) }

    it 'returns result' do
      expect(@conn_double).to receive(:write).with(:execute, '/.')
      result = subject.execute('/.')
      # expect(result).to be_a RedXML::Client::Result
    end
  end
end
