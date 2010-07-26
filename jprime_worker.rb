# This file contains the worker component of jprime.
#
# Author::    Jon Stacey (mailto:jon@jonsview.com)
# Copyright:: Copyright (c) 2010 Jon Stacey
# License::   Distributes under the same terms as Ruby

require 'drb/drb'
require 'rinda/ring'
require 'rinda/tuplespace'
require 'zlib'
require 'lib/jprime_tools'
# require 'profile'

# Generate primes between m <-> n
def generate_primes(m, n, multiples)
  puts "Generating primes between #{m} and #{n}"
  
  m = 2 if m < 2        # safety check, silly users

  cap   = Math.sqrt(n) + 1
  primes = (m..n).to_a

  i = 0
  while i < multiples.length
    p = multiples[i]
    i += 1
    
    break if p >= cap
    
    if (p >= m)
      start = p*2
    else 
      start = m + ((p - m % p)%p)
    end

    j = start
    while j <= n
      primes[j-m] = nil
      j += p
    end
  end
  
  return primes.compact
end

##############################
# Worker stuff               #
##############################

DRb.start_service
ts        = Rinda::RingFinger.primary 
multiples = (ts.read [:multiples, nil])[1]

begin
  while true
    job    = ts.take([:job, nil, nil, nil])
    primes = generate_primes(job[2].to_i, job[3].to_i, multiples)
    
    # Convert primes array to string
    primes_str = String.new
    primes.each do |p|
      primes_str << p.to_s + "\n"
    end
    
    Thread.start do # Don't wait while communicating with server
      # Compress the string
      compressed_string = Zlib::Deflate.deflate(primes_str)
      
      # Send compressed data set
      ts.write [:result, job[1], compressed_string]
    end
  end
rescue Exception => e
  # todo: do something with exceptions.
  p e
  puts "Retrying in 2 seconds..."
  sleep 2
  retry
end

exit