module WampRailsTest
  class TestSession
    attr_accessor :calls, :registrations, :publishes, :subscriptions

    def initialize
      self.clear
    end

    def is_open?
      true
    end

    def clear
      self.calls = {}
      self.registrations = {}
      self.publishes = {}
      self.subscriptions = {}
    end

    def call(procedure, args, kwargs, options, &callback)
      self.calls[procedure] = { p: procedure, a: args, k: kwargs, o:options, c: callback }
      raise Exception.new('test exception') if options[:error]

      object = self.registrations[procedure]
      handler = object != nil ? object[:h] : nil
      if handler
        response = handler.call(args, kwargs, {procedure: procedure, session: self})
        callback.call([response], nil, {}) if callback
      else
        callback.call([procedure, args, kwargs, options], nil, {}) if callback
      end
    end

    def register(procedure, handler, options=nil, interrupt=nil, &callback)
      self.registrations[procedure] = { p: procedure, h: handler, o:options, i: interrupt, c:callback }
      raise Exception.new('test exception') if options[:error]
      callback.call([procedure, handler, options, interrupt], nil, {}) if callback
    end

    def publish(topic, args, kwargs, options, &callback)
      self.publishes[topic] = { t: topic, a: args, k: kwargs, o:options, c: callback }
      raise Exception.new('test exception') if options[:error]

      object = self.subscriptions[topic]
      handler = object != nil ? object[:h] : nil
      if handler
        handler.call(args, kwargs, {topic: topic, session: self})
        callback.call([true], nil, {}) if callback
      else
        callback.call([topic, args, kwargs, options], nil, {}) if callback
      end
    end

    def subscribe(topic, handler, options={}, &callback)
      self.subscriptions[topic] = { t: topic, h: handler, o:options, c:callback }
      raise Exception.new('test exception') if options[:error]
      callback.call([topic, handler, options], nil, {}) if callback
    end
  end
end
