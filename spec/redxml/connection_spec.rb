require 'spec_helper'

RSpec.describe RedXML::Client::Connection do
  class TestDriver
    def initialize(*args)
    end

    def connect(*args)
    end
  end

  it 'connects' do
    options = { schema: 'test' }
    RedXML::Client::Connection.drivers['test'] = TestDriver
    connection = RedXML::Client::Connection.new(options)
    expect(connection.driver).to receive(:connect).with({})
    connection.connect
  end

  it 'finds driver by schema' do
    options = { schema: 'test' }
    RedXML::Client::Connection.drivers['test'] = TestDriver
    connection = RedXML::Client::Connection.new(options)
    expect(connection.driver).to be_a TestDriver
  end
end
