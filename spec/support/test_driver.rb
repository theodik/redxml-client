class TestDriver
  include RedXML::Client::DriverMixin

  attr_accessor :response

  def initialize(*args)
    @response =
      if args.first.is_a? String
        args.first
      else
        RedXML::Protocol::PacketBuilder.hello('Test-0.0.1').data
      end
  end

  def socket
    StringIO.new(@response.dup)
  end

  def address
    'TestDriver Server'
  end
end
