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

This also however has the side effect where all calls to the library are executed
synchronously (they will block the current thread) unless the callback is nil.

