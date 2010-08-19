# Load Tester

This is a simple load test for async get transactions. It uses EventMachine, and Synchrony to allow concurrency.

## Instalation
You can install its dependencies and then run it with:

    bundle install
    ruby load_tester.rb

It will run the load test using the configuration set in config.yml, check it out to see what options are available.

Also, if you want to use another database, you can do so by editing the database.yml file.
If you intend to use a different database adapter then sqlite3, you will also need
to add it to the Gemfile

## TODO
- Add a web interface with graphics, probably using sinatra and opencharts
- Add tests

