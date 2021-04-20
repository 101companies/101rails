module StringUtils
  class << self
    def upcase_first_char(str)
      head = str.first.upcase
      tail = str[1..]
      [head, tail].join
    end

    def downcase_first_char(str)
      head = str.first.downcase
      tail = str[1..]
      [head, tail].join
    end
  end
end
