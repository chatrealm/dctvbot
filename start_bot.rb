require 'yaml'

require_relative 'lib/dctvbot'
require_relative 'lib/watcher'

# Instance of dctvbot with yaml config file
dctvbot = DCTVBot.new(YAML.load(File.open 'config.test.yml'))
# Start watcher threads
Thread.new { Watcher.new(dctvbot, :check_dctv).start }
Thread.new { Watcher.new(dctvbot, :check_twitter, 300).start }
# Fire up bot
dctvbot.start
