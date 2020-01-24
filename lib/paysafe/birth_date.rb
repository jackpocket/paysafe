require 'paysafe/result'

module Paysafe
  class BirthDate < Result
    attributes :year, :month, :day

    def date
      @date ||= Date.new(year, month, day)
    end
  end
end
