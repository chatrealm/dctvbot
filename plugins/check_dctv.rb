# encoding: utf-8

module Plugins
  class CheckDCTV

    include Cinch::Plugin

    listen_to :check_dctv

    def initialize(*args)
      super
    end

    def listen(m)
    end
    
  end
end
