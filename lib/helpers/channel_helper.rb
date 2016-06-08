# file: lib/helpers/channel_helper.rb

class ChannelHelper
  def self.is_upcoming?(dctv_channel)
    dctv_channel['yt_upcoming']
  end

  def self.is_live?(dctv_channel)
    dctv_channel['nowonline'] == 'yes'
  end

  def self.is_official?(dctv_channel)
    dctv_channel['channel'] == 1
  end
end
