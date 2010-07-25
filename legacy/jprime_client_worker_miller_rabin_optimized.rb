# This second jprime worker implementation.
#
# Author::    Jon Stacey (mailto:jon@jonsview.com)
# Copyright:: Copyright (c) 2010 Jon Stacey
# License::   Distributes under the same terms as Ruby

require 'drb/drb'
require 'rinda/ring'
require 'rinda/tuplespace'

DRb.start_service
ts = Rinda::RingFinger.primary 

# Not a creation by Jon
def modPow(x, r, m)
  y = r
  z = x
  v = 1
  while y > 0
    u = y % 2
    t = y / 2
    if u == 1
      v = (v * z) % m
    end
    z = z * z % m
    y = t
  end
  return v
end

# Not a creation by Jon
def miller_rabin_pass(a, n)
  # compute s and d
  d = n - 1
  s = 0
  while d % 2 == 0 do
    d >>= 1
    s += 1
  end

  a_to_power = modPow(a, d, n)
  if a_to_power == 1
    return true
  end
  for i in 0...s do
    if a_to_power == n - 1
      return true
    end
    a_to_power = (a_to_power * a_to_power) % n
  end
  return (a_to_power == n - 1)
end

# IS a hacked creation by Jon as you can tell
def miller_rabin(n)
  # Try shortcuts on small numbers before doing costly tests
  # p_witnesses are potential witnesses for composites
  if n < 1373653
    p_witnesses = [2, 3]
  elsif n < 9080191
    p_witnesses = [32, 73]
  elsif n < 4759123141
    p_witnesses = [2, 7, 61]
  elsif n < 2152302898747
    p_witnesses = [2, 3, 5, 7, 11]
  elsif n < 3474749660383
    p_witnesses = [2, 3, 5, 7, 11, 13]
  elsif n < 341550071728321
    p_witnesses = [2, 3, 5, 7, 11, 13, 17]
  elsif n > 341550071728321
    puts "Ran out of shortcuts by Pomerance, Selfridge and Wagstaff and Jaeschke!"
    puts "You must now use Miller-Rabin for an arbitrarily large number which is costly."
    puts "Additionally, since it's not implemented, I'm just going to exit here and call it good"
    puts "Have a nice day!"
    exit
  end

  p_witnesses.each do |a|
    if (!miller_rabin_pass(a, n))
      return false
    end
  end

  return true
end

def generate_primes(low, high)
  puts "Generating primes between #{low} and #{high}"
  
  # safety check
  if low < 2
    low = 2
  end
  
  # todo: speed boost by only generating array with odd numbers to start with
  # and remvoing odd number checks from algorithm
  primes = (low..high).to_a

  primes.size.times do |i|
    unless miller_rabin(primes[i])
      primes[i] = nil
    end
  end

  primes.compact
end

begin
  while true
    job = ts.take([:job, nil, nil, nil], 30) # wait 30 seconds before timing out
    primes = generate_primes(job[2].to_i, job[3].to_i)
    
    ts.write [:result, job[1], primes]
  end
rescue Exception => e
  p e
  puts "No new jobs appeared so I'm exiting."
end


#jobs.each do |j|
#   puts j
# end

Process::exit