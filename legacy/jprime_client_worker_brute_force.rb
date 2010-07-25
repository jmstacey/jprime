# The first jprime worker implementation.
#
# Author::    Jon Stacey (mailto:jon@jonsview.com)
# Copyright:: Copyright (c) 2010 Jon Stacey
# License::   Distributes under the same terms as Ruby


# todo: Might get a small performance boost by only generating the
# array with odd numbers to start with and removing any odd number checks in the
# algorithm that might get run repeatedly.

require 'drb/drb'
require 'rinda/ring'
require 'rinda/tuplespace'

DRb.start_service

ts = Rinda::RingFinger.primary 

# Lucas–Lehmer primality test
# Retrieved from http://rosettacode.org/wiki/Lucas-Lehmer_test
def is_prime?(p)  
  if p == 2
    return true
  elsif p <= 1 || p % 2 == 0
    return false
  else
    (3 .. Math.sqrt(p)).step(2) do |i|
      if p % i == 0
        return false
      end
    end
    return true
  end
end

def generate_primes(low, high)
  puts "Generating primes between #{low} and #{high}"
  
  primes = (low..high).to_a

  primes.size.times do |i|
    unless is_prime?(primes[i])
      primes[i] = nil
    end
  end

  primes.compact
end

begin
  while true
    job = ts.take([:job, nil, nil, nil], 2)
    primes = generate_primes(job[2].to_i, job[3].to_i)
    
    ts.write [:result, job[1], primes]
  end
rescue Exception => e
  puts e
  puts "No more jobs so I'm exiting."
end

exit