AppBlade Services
=================

AppBlade services power the integration and plugin aspects of the AppBlade platform. These integration points are open source and under the MIT LICENSE.

How services work
-----------------

1. A service hooks are triggered by a background process when certain triggers are hit on AppBlade
2. If any service hooks are enabled on the project/account AppBlade will pass the request on the services process (this project)
3. "Services" will process the request and it's JSON payload

Service schema
---------------

The service schema is broadcasted via JSON on a <code>GET /</code>; AppBlade will consume this and display it in your project's settings.

See examples in the services directory to see how services are setup.

<table>
<caption>Available data-types</caption>
<thead>
<tr> <th>Schema type</th><th>Arguments</th><th>Description</th></tr>
</thead>
<tbody>
<tr> <th>string</th>  <td>*fields, options = {}</td> <td>A string data type (max-length 999)</td> </tr>
<tr> <th>password</th><td>*fields, options = {}</td> <td>A string with a masked input field</td> </tr>
<tr> <th>boolean</th> <td>*fields, options = {}</td> <td>A string with a value of 1 or 0, true/false, will be presented as a checkbox in AppBlade</td> </tr>
<tr> <th>oauth</th>   <td>*fields, options = {}</td> <td>An OAuth token for a given service (sensitive by default)</td> </tr>
</tbody>
</table>


<table>
<caption>Available options for the option hash</caption>
<thead>
<tr> <th>Key</th><th>Value</th><th>Description</th></tr>
</thead>
<tbody>
<tr> <th>required</th>   <td>Boolean</td>   <td>Fails validation if empty</td> </tr>
<tr> <th>sensitive</th>  <td>Boolean</td>   <td>Sensitive fields will only show their contents to the user that editted the integration last on AppBlade</td></tr>
<tr> <th>default</th>    <td>String</td>       <td>AppBlade will show a default value</td> </tr>
<tr> <th>collection</th> <td>[Strings]</td> <td>AppBlade will show a combination box with the array values passed</td> </tr>
</tbody>
</table>

Contributing
------------

1. Fork this project
2. Start the services project by running either <code>bundle exec services.rb</code> or <code>bundle exec ruby services.rb</code>
3. Create a new ruby file or modify one in /services with the following format:

    ```ruby
    class Service::ServiceName < Service

        Title = 'Service Name'
        Description = 'One line description'

    	string :foo, :required => true
        string :something, :something_else, :default => 'a'
        
        boolean :do_something
        
        oauth :named_service
        
        # Put your validations here (string only ATM)
        def settings_test
            return 'Success.'
        end

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
