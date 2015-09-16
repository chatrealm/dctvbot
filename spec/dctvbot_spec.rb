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
    it { is_expected.to respond_to(:callback) }
    it { is_expected.to respond_to(:channel_list) }
    it { is_expected.to respond_to(:channels) }
    it { is_expected.to respond_to(:config) }
    it { is_expected.to respond_to(:handlers) }
    it { is_expected.to respond_to(:irc) }
    it { is_expected.to respond_to(:last_connection_was_successful) }
    it { is_expected.to respond_to(:loggers) }
    it { is_expected.to respond_to(:modes) }
    it { is_expected.to respond_to(:nick) }
    it { is_expected.to respond_to(:plugins) }
    it { is_expected.to respond_to(:quitting) }
    it { is_expected.to respond_to(:user_list) }
  end

end
