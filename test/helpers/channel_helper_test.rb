# file: test/helpers/channel_helper_test.rb

require 'test_helper'

require 'helpers/channel_helper'

class ChannelHelperTest < Minitest::Test

	def setup
		@mock_channel = {
			'nowonline' => nil,
			'yt_upcoming' => nil,
			'channel' => nil
		}
	end

	def test_is_upcoming
		@mock_channel['yt_upcoming'] = true
		assert ChannelHelper.is_upcoming?(@mock_channel)

		@mock_channel['yt_upcoming'] = false
		refute ChannelHelper.is_upcoming?(@mock_channel)
	end

	def test_is_live
		@mock_channel['nowonline'] = 'yes'
		assert ChannelHelper.is_live?(@mock_channel)

		@mock_channel['nowonline'] = 'no'
		refute ChannelHelper.is_live?(@mock_channel)
	end

	def test_is_official
		@mock_channel['channel'] = 1
		assert ChannelHelper.is_official?(@mock_channel)

		@mock_channel['channel'] = 2
		refute ChannelHelper.is_official?(@mock_channel)
	end

end
