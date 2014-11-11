require 'spec_helper'

RSpec.describe RedXML::Client do
  let(:options) { { scheme: 'tcp', host: 'localhost', port: 33965 } }

  before do
    conn = class_double('RedXML::Client::Connection').as_stubbed_const
    @conn_double = double('connection')
    allow(conn).to receive(:new).with(any_args).and_return(@conn_double)
  end

  describe '.connect' do
    it 'returns client' do
      client = RedXML::Client.connect(options)
      expect(client).to be_a RedXML::Client
    end

    it 'accepts block with client as an argument' do
      expect(@conn_double).to receive(:close).with(no_args)
      expect(@conn_double).to receive(:closed?)
      RedXML::Client.connect(options) do |client|
        expect(client).to be_a RedXML::Client
      end
    end

    it 'connects and disconnect' do
      closed = false
      expect(@conn_double).to receive(:closed?) { closed }.at_least(:once)
      expect(@conn_double).to receive(:close).with(no_args) { closed = true }
      client = nil
      RedXML::Client.connect(options) do |c|
        client = c
        expect(client).to_not be_closed
      end
      expect(client).to be_closed
    end
  end

  context 'with options' do
    subject { RedXML::Client.connect(options) }

    describe '#server_version' do
      it 'returns connected server version' do
        expect(@conn_double).to receive(:server_version).and_return('Test-0.0.1')
        expect(subject.server_version).to eq 'Test-0.0.1'
      end
    end

    describe '#execute' do
      it 'returns result' do
        expect(@conn_double).to receive(:send).with(:execute, '/.')
        subject.execute('/.')
      end
    end

    describe '#ping' do
      it 'pings' do
        expect(@conn_double).to receive(:send).with(:ping)
        subject.ping
      end
    end
  end
end
