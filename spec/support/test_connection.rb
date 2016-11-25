require 'wamp_client/connection'

module WampRailsTest
  class TestConnection < WampClient::Connection

    def open
      EM.run do
        self.session = WampRailsTest::TestSession.new
        @on_join.call(self.session, {})
      end
    end

    def close
      EM.stop
    end

  end
end
