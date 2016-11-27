require 'thread'
require 'wamp_client/connection'

module WampRails
  module Worker
    class BaseWorker
      attr_accessor :options, :wamp, :name, :active, :verbose
      attr_accessor :registrations, :subscriptions

      # Called when the WAMP session presents a challenge
      # @param authmethod [String]
      # @param extra [Hash]
      @on_challenge
      def on_challenge(&on_challenge)
        @on_challenge = on_challenge
      end

      # Returns true if the connection is active
      def is_active?
        self.active
      end

      # Waits for the session to become active
      def wait_for_active
        until self.is_active?
        end
      end

      # Constructor for creating a client.  Options are
      # @param options [Hash] The different options to pass to the connection
      # @option options [String] :name - The name of the WAMP Client
      # @option options [WampClient::Connection] :wamp - Allows a different WAMP to be passed in
      # @option options [String] :uri The uri of the WAMP router to connect to
      # @option options [String] :realm The realm to connect to
      # @option options [String, nil] :protocol The protocol (default if wamp.2.json)
      # @option options [String, nil] :authid The id to authenticate with
      # @option options [Array, nil] :authmethods The different auth methods that the client supports
      # @option options [Hash] :headers Custom headers to include during the connection
      # @option options [WampClient::Serializer::Base] :serializer The serializer to use (default is json)
      def initialize(options=nil)
        self.options = options || {}
        self.registrations = []
        self.subscriptions = []
        self.name = self.options[:name] || 'default'
        self.wamp = self.options[:wamp] || WampClient::Connection.new(self.options)
        self.verbose = self.options[:verbose]
        self.active = false

        # WAMP initialization.   Note that all callbacks are called on the reactor thread
        self.wamp.on_connect do
          puts "WAMP Rails Client #{self.name} connection established" if self.verbose
        end

        self.wamp.on_join do |session, details|
          puts "WAMP Rails Client #{self.name} was established" if self.verbose
          self.active = true

          # Register the procedures
          self.registrations.each do |command|
            self._execute_command(command)
          end

          # Subscribe to the topics
          self.subscriptions.each do |command|
            self._execute_command(command)
          end
        end

        self.wamp.on_leave do |reason, details|
          puts "WAMP Rails Client #{self.name} left because '#{reason}'" if self.verbose
          self.active = false
        end

        self.wamp.on_disconnect do |reason|
          puts "WAMP Rails Client #{self.name} disconnected because '#{reason}'" if self.verbose
          self.active = false
        end

        self.wamp.on_challenge do |authmethod, extra|
          if @on_challenge
            @on_challenge.call(authmethod, extra)
          else
            puts "WAMP Rails Client #{self.name} auth challenge was received but no method was implemented." if self.verbose
            nil
          end
        end

        # Catch SIGINT
        Signal.trap('INT') { self.close }
        Signal.trap('TERM') { self.close }
      end

      # Opens the connection
      def open
        EM.tick_loop do
          unless self.cmd_queue.empty?
            command = self.cmd_queue.pop
            self._execute_command(command)
          end
        end
        self.wamp.open
      end

      # Closes the connection
      def close
        begin
          self.wamp.close
        rescue Exception => e
          puts "WAMP Rails #{name} exception while closing #{e.to_s}"
        end
      end

      def cmd_queue
        # Override in subclass
      end

      #region Route Methods

      # Used to configure the routes for the client
      def routes(&block)
        self.instance_eval(&block)
      end

      # Adds a procedure to the client
      def add_procedure(procedure, klass, options=nil)
        options ||= {}
        raise WampRails::Error.new('"add_procedure" must be called BEFORE the connection is active') if self.is_active?
        self.registrations << WampRails::Command::Register.new(nil, procedure, klass, options, self)
      end

      # Adds a subscription to the client
      def add_subscription(topic, klass, options=nil)
        options ||= {}
        raise WampRails::Error.new('"add_subscription" must be called BEFORE the connection is active') if self.is_active?
        self.subscriptions << WampRails::Command::Subscribe.new(nil, topic, klass, options, self)
      end

      #endregion


      #region Private Methods

      # Executes the command
      # @param [WampRails::Command::Base] - The command to execute
      def _execute_command(command)
        begin
          unless self.is_active?
            raise WampRails::Error.new("WAMP Rails Client #{self.name} is currently not active.")
          end

          command.execute(self.wamp.session)
        rescue Exception => e
          puts e.to_s if self.verbose
          command.callback(nil, {error: 'wamp_rails.error', args: [e.to_s], kwargs: nil}, nil)
        end
      end
      #endregion

    end

  end
end
