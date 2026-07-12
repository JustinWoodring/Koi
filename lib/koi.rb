# frozen_string_literal: true
module Koi
  VERSION = "1.0.0"
end

require_relative './koi/server'

module Koi
  class Pond 
    def initialize(config)
      @config = config
    end

    def run
      server = Koi::Server.new(@config)
      server.run
    end
  end
end
