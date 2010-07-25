# This library adds a primality test to Ruby's
# builtin Integer class. 
#
# Author::    Jon Stacey (mailto:jon@jonsview.com)
# Copyright:: Public Domain
# License::   Distributes under the same terms as Ruby

class Integer
  
  # Test to see if number is a prime number
  #
  # Lucas–Lehmer primality test
  # Retrieved from http://rosettacode.org/wiki/Lucas-Lehmer_test
  def prime?()
    p = self
  
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
end