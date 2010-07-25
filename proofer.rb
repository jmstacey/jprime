# Proves [double checks] the validity of prime number
# contained within a specified compressed prime data file.
#
# Author::    Jon Stacey (mailto:jon@jonsview.com)
# Copyright:: Copyright (c) 2010 Jon Stacey
# License::   Distributes under the same terms as Ruby

require 'zlib'
require 'lib/primality'
require 'lib/jprime_tools'

file = "/Users/jon/Desktop/0.txt" # The compressed data file to verify

# Read the contents of file
compressed_data = String.new
File.open(file, "r") { |f|
  compressed_data = f.read
}

# Convert string to array
primes = Array.new
Zlib::Inflate.inflate(compressed_data).split("\n").each {|p| primes << p.to_i}

# Assert that each number is indeed a prime number
complaints = false
primes.each do |p|
  if !p.prime?
    complaints = true
    puts "No! #{p} is not a prime!"
  end
end

puts "All numbers are indeed prime. Life is good :-)" unless complaints