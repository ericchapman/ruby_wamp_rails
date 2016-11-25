require 'wamp_rails'

module WampRailsTest
  class TestRegisterController < WampRails::Controller::Register

    def called
      [(args[0] + kwargs[:number]), details, session]
    end

  end
end