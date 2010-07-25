# This file contains the jprime library. Functions that
# are used throughout the program.
#
# Author::    Jon Stacey (mailto:jon@jonsview.com)
# Copyright:: Copyright (c) 2010 Jon Stacey
# License::   Distributes under the same terms as Ruby

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

# Test if given number is a prime multiple
def prime_multiple?(n, multiples)
  cap = Math.sqrt(n) + 1
  
  multiples.each do |m|
    break if m >= cap
    return false if n % m == 0
  end
  
  return true
end