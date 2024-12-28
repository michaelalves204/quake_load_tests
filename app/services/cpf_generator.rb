# frozen_string_literal: true

module Services
  class CpfGenerator
    def initialize(mask)
      @mask = mask
    end

    def call
      return cpf.gsub(/(\d{3})(\d{3})(\d{3})(\d{2})/, '\1.\2.\3-\4') if @mask

      cpf
    end

    private

    def cpf
      @cpf ||= begin
        digits = nine_digits

        [10, 11].each do |multiple|
          result = sum_digits(multiple, digits)

          result %= 11

          digits <<= result < 2 ? '0' : (11 - result).to_s
        end
        digits
      end
    end

    def nine_digits
      @nine_digits ||= begin
        digits = Array.new(9) { rand(0..9) }
        digits.join
      end
    end

    def sum_digits(multiple, digits)
      sum = 0
      digits.split('').each_with_index do |digit, index|
        digit = digit.to_i
        index = (multiple - index)
        sum += (digit * index)
      end
      sum
    end
  end
end
