module StringUtils
  class << self

    def upcase_first_char(str)
      head = str.first.upcase
      tail = str[1..-1]
      [head, tail].join
    end

  end
end
