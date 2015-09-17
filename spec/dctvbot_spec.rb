require 'dctvbot'

describe DCTVBot do

  subject do
    DCTVBot.new do
      configure do |c|
        c.server  = "irc.chatrealm.net"
        c.port    = "6667"

        c.nick      = "dctvbot"
        c.user      = "Cinch"
        c.realname  = "DCTV Bot"
        c.channels  = [ "#testbot" ]
      end
    end
  end

  describe "attributes" do
    it { is_expected.to respond_to(:channels) }
    it { is_expected.to respond_to(:config) }
    it { is_expected.to respond_to(:nick) }
  end

  # describe "#custom_log_file" do
  #   # Figure out how to test this
  # end

end
