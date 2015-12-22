# siji
### Simple Single Login Api service
Built using Ruby, Sinatra and MongoDB.
This application currently running in heroku PaaS
    https://siji.herokuapp.com 
If you want to fork and run this project locally in your machine, just run bundle install and run
``` rackup ``` command

### API documentation
Here are few of the api call that available:
- `/api/signup` POST method with payload json such as `{"email":"test@test.com", "password":"Test1234"}` this will return email registration
- `/api/login` POST method with payload json such as `{"email":"test@test.com", "password":"Test1234"}` this will return json object `{"auth_token":"e74299e7d7ac457f8e6ea59f69dsdfsd","expired_time":"2015-12-22T17:42:43.757-05:00"}%`
- `/api/users` GET method query all users by passing the auth-token in header
- `/api/users/id/:id` GET method query user within :id by passing the auth-token in header
- `/api/users/name/:name`GET method query user with :name by passing the auth-token in header
- `/api/users/:id` PUT method update user within :idby passing the auth-token in header
- `/api/users/:id` DELETE method delete user within :id by passing the auth-token in header

TODO
Enhanced the roles assignment and add admin control 