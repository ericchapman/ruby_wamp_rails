require 'thread'
require 'wamp_client/connection'

module WampRails

  class Client
    attr_accessor :options, :wamp, :cmd_queue, :thread, :name, :active, :verbose
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

    # Constructor for creating a client.  Options are
    # @param options [Hash] The different options to pass to the connection
    # @option options [String] :name - The name of the WAMP Client
    # @option options [Array] :registrations - The different registrations
    # @option options [Array] :subscriptions - The different subscriptions
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
      self.cmd_queue = Queue.new
      self.registrations = self.options[:registrations] || []
      self.subscriptions = self.options[:subscriptions] || []
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
        self.registrations.each do |registration|
          self._queue_command(registration)
        end

        # Subscribe to the topics
        self.subscriptions.each do |subscription|
          self._queue_command(subscription)
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

      # Create the background thread
      self.thread = Thread.new do
        EM.tick_loop do
          unless self.cmd_queue.empty?
            command = self.cmd_queue.pop
            self._execute_command(command)
          end
        end
        self.wamp.open
      end

      # Catch SIGINT
      Signal.trap('INT') { self.close }
      Signal.trap('TERM') { self.close }
    end

    # Closes the connection
    def close
      self.wamp.close
    end

    #region WAMP Methods

    # Performs a WAMP call
    # @note This method is blocking if the callback is not nil
    def call(procedure, args=nil, kwargs=nil, options={}, &callback)
      command = WampRails::Command::Call.new(procedure, args, kwargs, options, self)
      self._queue_command(command, callback)
    end

    # Performs a WAMP publish
    # @note This method is blocking if the callback is not nil
    def publish(topic, args=nil, kwargs=nil, options={}, &callback)
      command = WampRails::Command::Publish.new(topic, args, kwargs, options, self)
      self._queue_command(command, callback)
    end

    # Performs a WAMP register
    # @note This method is blocking if the callback is not nil
    def register(procedure, klass, options={}, &callback)
      command = WampRails::Command::Register.new(procedure, klass, options, self)
      self._queue_command(command, callback)
    end

    # Performs a WAMP subscribe
    # @note This method is blocking if the callback is not nil
    def subscribe(topic, klass, options={}, &callback)
      command = WampRails::Command::Subscribe.new(topic, klass, options, self)
      self._queue_command(command, callback)
    end

    #endregion

    #region Private Methods

    # Queues the command and blocks it the callback is not nil
    # @param [WampRails::Command::Base] - The command to queue
    # @param [Block] - The block to call when complete
    def _queue_command(command, callback=nil)

      # If the current thread is the EM thread, execute the command.  Else put it in the queue
      if self.thread == Thread.current
        self._execute_command(command)
      else
        self.cmd_queue.push(command)
      end

      # If the callback is defined, block until it finishes
      if callback
        callback_args = command.queue.pop
        callback.call(callback_args.result, callback_args.error, callback_args.details)
      end
    end

    # Executes the command
    # @param [WampRails::Command::Base] - The command to execute
    def _execute_command(command)
      begin
        unless self.is_active?
          raise WampRails::Error.new("WAMP Rails Client #{self.name} is currently not active.")
        end

        command.execute
      rescue Exception => e
        puts e.to_s if self.verbose
        command.callback(nil, {error: 'wamp_rails.error', args: [e.to_s], kwargs: nil}, nil)
      end
    end
    #endregion

  end
end
