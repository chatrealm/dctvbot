require 'dctvbot'

describe DCTVBot do

  let(:dctvbot) do
    DCTVBot.new do
      configure do |c|
        c.server  = 'irc.chatrealm.net'
        c.port    = 6667

        c.nick      = 'testbot'
        c.user      = 'Cinch'
        c.realname  = 'Test Bot'
        c.channels  = [ '#testbot' ]
      end
    end
  end

  describe '#new' do
    it 'returns a DCTVBot object' do
      expect(dctvbot).to be_an_instance_of(DCTVBot)
    end
  end

  describe '#assignedchannels' do
    it 'exists' do
      expect(dctvbot).to respond_to(:assignedchannels)
    end
  end

  # describe "#custom_log_file" do
  #   # Figure out how to test this
  # end

end
