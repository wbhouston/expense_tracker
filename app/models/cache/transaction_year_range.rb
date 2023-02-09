# frozen_string_literal: true

module Cache
  class TransactionYearRange
    include ::Redis::Objects

    attr_reader :id

    def initialize
      @id = "#{self.class.name}-id"
    end

    value :max_transaction_year_value, expire: 1.hour
    value :min_transaction_year_value, expire: 1.hour

    def range
      (min_transaction_year.to_i..max_transaction_year.to_i).to_a.reverse
    end

    def max_transaction_year
      max_transaction_year_value.value ||= max_year_query
    end

    def min_transaction_year
      min_transaction_year_value.value ||= min_year_query
    end

    private

    def max_year_query
      Transaction.all.active.select(
        Transaction.extract_year_from_date.maximum.as('maximum'),
      ).limit(1)[0].maximum
    end

    def min_year_query
      Transaction.all.active.select(
        Transaction.extract_year_from_date.minimum.as('minimum'),
      ).limit(1)[0].minimum
    end
  end
end
