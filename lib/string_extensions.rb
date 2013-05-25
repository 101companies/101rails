# Inject some extra functions to class String
module StringExtensions

  # Extend the class String with this module's class methods
  # when this module is included.
  def self.included(base)
    String.extend StringExtensions::ClassMethods
  end

  # Class-methods for String
  module ClassMethods
    # Characters which may be used in random strings
    RAND_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789"

    #
    # random string of 'len' characters length
    def random_string(len)
      rand_max = RAND_CHARS.size
      ret = ""
      len.times{ ret << RAND_CHARS[rand(rand_max)] }
      ret
    end
  end

end
