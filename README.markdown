jprime
=========

jprime is an experimental distributed prime number generator written in Ruby.

Configuration
-----------

Adjust the job size and target number in jprime_server.rb

Usage
-----------

1. Launch jprime_server.rb
2. Launch a jprime_worker.rb for every processor/core across all the computers you want to distribute these calculations to! Or try jprime_worker_launcher.rb which will try to launch the appropriate number of workers for you.

Copyright
------------

Distributes under the same terms as Ruby