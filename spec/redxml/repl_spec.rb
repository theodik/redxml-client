require 'spec_helper'
require 'timeout'

RSpec.xdescribe RedXML::Client::REPL do
  # FIXME: Readline somehow doesnt work with $stdin

  def replace_stdio(output, input)
    orig_out, orig_in = $stdout, $stdin
    $stdout, $stdin = output, input
    yield
  ensure
    $stdout, $stdin = orig_out, orig_in
  end

  before do
    RedXML::Client::Connection.drivers['test'] = TestDriver
  end
  let(:client) { RedXML::Client.new(scheme: 'test') }

  it 'sends xquery' do
    expect(client).to receive(:execute).with('/test')

    input = StringIO.new("/test\nquit\n")
    output = StringIO.new
    replace_stdio(output, input) do
      subject = described_class.new(client)

      Timeout.timeout(1) do
        subject.repl
      end
    end
  end

  it 'exits and closes connection' do
    expect(client).to receive(:close)

    input = StringIO.new("quit\n")
    output = StringIO.new

    replace_stdio(output, input) do
      subject = described_class.new(client)

      Timeout.timeout(1) do
        subject.repl
      end
    end
  end

  it 'sends ping' do
    expect(client).to receive(:ping)

    input = StringIO.new("ping\nquit\n")
    output = StringIO.new

    replace_stdio(output, input) do
      subject = described_class.new(client)

      Timeout.timeout(1) do
        subject.repl
      end
    end
  end
end
