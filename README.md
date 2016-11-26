# WampRails

This library allows the GEM [wamp_client](https://github.com/ericchapman/ruby_wamp_client) 
to be integrated into a Rails application.

The 'wamp_client' GEM uses the Event Machine implementation of Web Sockets to
connect to the WAMP router.  This requires the Rails application to spin off
an independent thread where the EM reactor will run.

The library also wraps the connection logic under the library so that the 
Rails application doesn't need to handle it.

All calls to the library are implemented as "commands".  When a call is made to
the client, the library will create a command and do the following

 - If the thread is the same thread as the EM reactor, it will immediately
   execute the command
 - Else place the command into the queue that the reactor will check on every
   tick
   
This ensures that the Rails application does not need to worry about the thread.

This however has the side effect where all calls to the library are executed
synchronously (they will block the current thread) unless the callback is nil.

## Commands

The client currently supports the following commands from the WampClient library

 - call
 - publish
 - register
 - subscribe
 
The methods have the same parameters as the WampClient library

## Controllers

The 'register' and 'subscribe' commands require 'handlers' to be implemented.
In order to ensure thread safety and consistency with Rails, the handlers
are implemented as 'controller' classes.

When a call or publish is received, the library will instantiate the supplied
class with following methods available

 - args (Array) - The arguments
 - kwargs (Hash) - The keyword arguments
 - details (Hash) - The details
 - client [WampRails::Client) - The client.  This can be used if the 
   handler needs to send a Wamp message

### Register
To create a register controller, create a class that subclasses from
'WampRails::Controller::Procedure' and implements 'handler'.  See below

``` ruby
class MyRegisterController < WampRails:::Controller::Procedure

  def handler
    the_args = self.args
    the_kwargs = self.kwargs
    the_details = self.details
    the_client = self.client
   
    # Do Something
   
    # Return the result (see WampClient for more details on implementing procedures)
    true
  end

end
```

### Subscribe
To create a subscribe controller, create a class that subclasses from
'WampRails::Controller::Subscription' and implements 'handler'.  See below

``` ruby
class MySubscribeController < WampRails:::Controller::Subscription

  def handler
    the_args = self.args
    the_kwargs = self.kwargs
    the_details = self.details
    the_client = self.client
   
    # Do Something
   
  end

end
```
