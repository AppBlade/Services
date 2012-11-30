AppBlade Services
=================

AppBlade services power the integration and plugin aspects of the AppBlade platform. These integration points are open source and under the MIT LICENSE.

How services work
-----------------

1. A service hooks are triggered by a background process when certain triggers are hit on AppBlade
2. If any service hooks are enabled on the project/account AppBlade will pass the request on the services process (this project)
3. "Services" will process the request and it's JSON payload

Contributing
------------

1. Fork this project
2. Start the services project by running either <code>bundle exec services.rb</code> or <code>bundle exec ruby services.rb</code>
3. Create a new ruby file or modify one in /services with the following format:

    ```ruby
    class Service::ServiceName < Service

    	string :api_key, :required => true

    	# Do something when a unique crash report comes through
    	def receive_crash_report 
    	end

    	# Do something when feedback is recieved
    	def recieve_feedback
    	end

    end
    ```

4. Add any any needed tests in /tests
5. Add documentation in /docs
6. Add any dependencies to the Gemfile
7. Send a pull request to [AppBlade Services](https://github.com/AppBlade/Services)
