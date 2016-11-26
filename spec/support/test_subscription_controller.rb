module WampRailsTest
  class TestSubscriptionController < WampRails::Controller::Subscription
    @@count = 0

    def self.count
      @@count
    end

    def handler
      @@count = args[0] + kwargs[:number]
      nil
    end

  end
end
