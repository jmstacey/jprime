# This helper utility launches a worker process
# for every available processor ont he current system.
#
# Author::    Jon Stacey (mailto:jon@jonsview.com)
# Copyright:: Copyright (c) 2010 Jon Stacey
# License::   Distributes under the same terms as Ruby

ruby_path = `which ruby1.9`

if RUBY_PLATFORM.downcase.include?("darwin")
  cpu_count = `hwprefs cpu_count`
elsif RUBY_PLATFORM.downcase.include?("linux")
  cpu_count = `cat /proc/cpuinfo | grep processor | wc -l`
end

cpu_count = Integer(cpu_count)
  
cpu_count.times do |i|
  pid = fork { system "#{ruby_path} jprime_client_worker.rb" }
  Process.detach(pid)
  
  puts "Process #{i + 1} started."
end