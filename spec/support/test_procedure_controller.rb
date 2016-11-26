require 'wamp_rails'

module WampRailsTest
  class TestProcedureController < WampRails::Controller::Procedure

    def handler
      [(args[0] + kwargs[:number]), details, client]
    end

  end
end