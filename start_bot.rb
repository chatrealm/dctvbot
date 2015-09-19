require 'yaml'

require_relative 'lib/dctvbot'
require_relative 'lib/watcher'

# Instance of dctvbot with yaml config file
dctvbot = DCTVBot.new(YAML.load(File.open 'config.test.yml'))

Thread.new { Watcher.new(dctvbot, :check_dctv).start }
# TODO: Uncomment this thread before putting in production
# Thread.new { Watcher.new(dctvbot, :check_twitter, 300).start }

dctvbot.start
