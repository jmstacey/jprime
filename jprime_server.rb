# This file contains the server component of jprime.
#
# todo: add simple error checking so that workers
#       can disconnect without losing data sets.
#
# Author::    Jon Stacey (mailto:jon@jonsview.com)
# Copyright:: Copyright (c) 2010 Jon Stacey
# License::   Distributes under the same terms as Ruby

# Configuration Directives
# Note: target must be divisible by job_size!
target   = 1000000000 # Max number to look at for primes
job_size = 1000000    # Number chunk size per job
data_dir = "/Users/jon/Desktop/primes/" # Directory in which to dump data files


require 'rinda/ring'
require 'rinda/tuplespace'
require 'zlib'
require 'lib/jprime_tools'
# require 'profile'

DRb.start_service
ts = Rinda::TupleSpace.new
Rinda::RingServer.new ts

# Prime Part 1: Pregenerate possible prime multiples
puts "Pregenerating prime multiples..."
multiples = [2]

3.step(Math.sqrt(target).ceil, 2) do |i|
  multiples << i if prime_multiple?(i, multiples)
end

ts.write [:multiples, multiples]
puts "Finished generating #{multiples.length} prime multiples"

##############################
# Start administrative tasks #
##############################

# todo: move some of this mess to a lib file and streamline

# Initialize Job pool
job_pool_size = target / job_size
finished_jobs = 0
last          = 0
jobs          = Array.new

puts "Initializing job pool..."

job_pool_size.times do |t|
  n = (last + job_size)     # todo: make this more ruby-like/elegant
  jobs << [t, last, n - 1]
  last = n
end

jobs.reverse.each do |j|
  ts.write [:job, j[0], j[1], j[2]]
end
puts "Job pool initialized with #{job_pool_size} jobs."

# Register tuplespace observers
job_observer     = ts.notify "take", [:job, nil, nil, nil]
results_observer = ts.notify 'write', [:result, nil, nil]

# Start threads for observer so we don't block
Thread.start do
  job_observer.each {|j| puts "Started job ##{j[1][1]} (#{j[1][2]} to #{j[1][3]})"}
end

# We're ready to roll now!
puts "\n\nFully initialized. It's time to launch the worker clients.\n"
puts "\nProgress report"
puts "-" * 30

##############################
# While processing tasks     #
##############################

# Block process while waiting for jobs to finish
results_observer.each do |r|
  puts "Finished job ##{r[1][1]}"
  
  Thread.start do
    open(File.join(data_dir, r[1][1].to_s + '.txt'), 'w') do |file|
      file.puts r[1][2]
      # file.puts Zlib::Inflate.inflate(r[1][2])
    end

    ts.take [:result, r[1][1], nil] # Remove the processed results from queue
  end
  
  finished_jobs = finished_jobs + 1
  if (finished_jobs == job_pool_size)
    break
  end
end

# Make sure all results are processed before exiting
puts "Procesing results (i.e. writing files...)"
remaining = (ts.read_all([:result, nil, nil])).length
while remaining > 0
  puts "#{remaining} jobs left to process"
  sleep 1
  remaining = (ts.read_all([:result, nil, nil])).length
end


puts "-" * 30
puts "\n\nAll jobs completed! Shuting down\n\n"

exit

# Wait until the user explicitly kills the server.
# DRb.thread.join
