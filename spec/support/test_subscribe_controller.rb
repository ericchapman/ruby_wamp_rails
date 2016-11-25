module WampRailsTest
  class TestSubscribeController < WampRails::Controller::Subscribe
    @@count = 0

    def self.count
      @@count
    end

    def published
      @@count = args[0] + kwargs[:number]
      nil
    end

  end
end
