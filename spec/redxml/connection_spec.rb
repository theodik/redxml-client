require 'spec_helper'

RSpec.describe RedXML::Client::Connection do
  let(:options) { { scheme: 'test' } }
  subject { RedXML::Client::Connection.new(options) }

  context '#new' do
    it 'finds driver by schema' do
      options = { scheme: 'test' }
      RedXML::Client::Connection.drivers['test'] = TestDriver
      connection = RedXML::Client::Connection.new(options)
      expect(connection.driver).to be_a TestDriver
    end

    it 'fail with unsupported schema' do
      options = { schema: 'fail' }
      expect {
        RedXML::Client::Connection.new(options)
      }.to raise_error(ArgumentError)
    end

    it 'reads server version' do
      options = { scheme: 'test' }
      RedXML::Client::Connection.drivers['test'] =
        class_double('TestDriver').tap do |klass|
          expect(klass).to receive(:new) do
            TestDriver.new.tap do |driver|
              driver.response = RedXML::Protocol::PacketBuilder
                                .hello('Test-0.0.1').data
            end
          end
        end
      subject = RedXML::Client::Connection.new(options)

      expect(subject.server_version).to eq 'Test-0.0.1'
    end

    it 'fails when server sends wrong hello' do
      options = { scheme: 'test' }
      RedXML::Client::Connection.drivers['test'] =
        class_double('TestDriver').tap do |klass|
          expect(klass).to receive(:new) do
            TestDriver.new.tap do |driver|
              driver.response = RedXML::Protocol::PacketBuilder.ping.data
            end
          end
        end

      expect {
        RedXML::Client::Connection.new(options)
      }.to raise_error(RuntimeError)
    end

    it 'fails when server sends wrong hello' do
      options = { scheme: 'test' }
      RedXML::Client::Connection.drivers['test'] =
        class_double('TestDriver').tap do |klass|
          expect(klass).to receive(:new) { TestDriver.new('') }
        end

      expect {
        RedXML::Client::Connection.new(options)
      }.to raise_error(RuntimeError)
    end
  end

  describe '#send' do
    let(:driver) { double('driver') }
    before do
      RedXML::Client::Connection.drivers['test'] = TestDriver
    end
    after do
      RedXML::Client::Connection.drivers['test'] = nil
    end

    it 'write packet' do
      command = :execute
      param = '/test'
      subject.driver.response = RedXML::Protocol::PacketBuilder
                                .execute(param).data

      expect(subject.driver).to receive(:write) do |packet|
        expect(packet).to be_a RedXML::Protocol::Packet
        expect(packet.command).to eq command
        expect(packet.param).to eq param
      end

      response = subject.send(command, param)

      expect(response).to eq param
    end

    it 'fails with error response' do
      subject.driver.response = RedXML::Protocol::PacketBuilder
                                .execute('test')
                                .error('test error message')
                                .data
      expect {
        subject.send(:execute, 'test')
      }.to raise_error(RedXML::Client::ServerError, 'test error message')
    end
  end

  context 'commands' do
    before(:all) do
      RedXML::Client::Connection.drivers['test'] = TestDriver
    end

    it 'pings' do
      subject.driver.response = RedXML::Protocol::PacketBuilder.ping.data
      response = subject.send(:ping)
      expect(response).to eq ''
    end

    it 'begins' do
      subject.driver.response = RedXML::Protocol::PacketBuilder.begin.data
      response = subject.send(:begin)
      expect(response).to eq ''
    end

    it 'commits' do
      subject.driver.response = RedXML::Protocol::PacketBuilder.commit.data
      response = subject.send(:commit)
      expect(response).to eq ''
    end

    it 'rollbacks' do
      subject.driver.response = RedXML::Protocol::PacketBuilder.rollback.data
      response = subject.send(:rollback)
      expect(response).to eq ''
    end
  end
end
