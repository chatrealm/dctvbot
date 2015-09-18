require 'cinch'
require 'json'
require 'net/http'

class DCTVBot < Cinch::Bot
  # Assigned channels
  attr_accessor :assignedchannels

  # Official channel live boolean
  attr_accessor :official_live

  # Command Control
  # attr_accessor :cleverbot_enabled, :dctv_commands_enabled

  # Twitter Endpoint
  # attr_accessor :twitter

  def initialize(&block)
    super

    update_assignedchannels

    # Handle SIGINT (Ctrl-C)
    trap "SIGINT" do
      debug "Caught SIGINT, quitting..."
      quit
    end

    # Handle SIGTERM (Kill Command)
    trap "SIGTERM" do
      debug "Caught SIGTERM, quitting..."
      quit
    end
  end

  # Set a custom log file for the bot
  def custom_log_file(file_name, log_level=:info)
    file = open(file_name, 'a')
    file.sync = true # Write buffered data immediately
    @loggers << Cinch::Logger::FormattedLogger.new(file)
    @loggers.first.level = log_level
  end

  def primary_channel
    Channel(@channels.first)
  end

  def update_dctv_status
    update_assignedchannels
    update_official_live
  end

  def announce_stream(stream)
    name = stream['friendlyalias']
    url = stream['urltoplayer']
    description = stream['twitch_yt_description']
    upcoming = stream['yt_upcoming']

    # Set announce message
    output = get_announce_message(name, url, description, upcoming)
    # Announce channel
    primary_channel.send(output)
    # Update topic, if channel is official
    update_channel_topic(output) if stream['channel'] == 1
  end

  def get_announce_message(name, url, description=nil, upcoming=false)
    status = Format(:white, :red, " LIVE ")
    status = Format(:black, :yellow, " UP NEXT ") if upcoming
    msg = "#{status} #{name}"
    msg += " - #{description}" unless description.empty?
    msg += " - #{url}"
  end

  def update_channel_topic(title, irc_channel=nil)
    irc_channel = primary_channel if irc_channel.nil?
    topic_array = irc_channel.topic.split("|")
    topic_array.shift
    new_topic = title + " |" + topic_array.join("|")
    irc_channel.topic = new_topic
  end

  private

    def update_assignedchannels
      response = Net::HTTP.get_response(URI.parse('http://diamondclub.tv/api/channelsv2.php?v=3'))
      @assignedchannels = JSON.parse(response.body)['assignedchannels']
    end

    def update_official_live
      @official_live = false
      @assignedchannels.each do |stream|
        @official_live = true if stream['nowonline'] == "yes" && stream['channel'] == 1
      end
    end

end
