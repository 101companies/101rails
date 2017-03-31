module StringUtils
  class << self

    def upcase_first_char(str)
      [ ActiveSupport::Multibyte::Chars.new(str.mb_chars.slice(0,1)).upcase.to_s, str.mb_chars.slice(1..-1) ].join
    end

  end
end
