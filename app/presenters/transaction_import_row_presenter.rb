# frozen_string_literal: true

class TransactionImportRowPresenter
  attr_reader :row, :transaction_import

  delegate(
    :amount_mapping_type,
    :column_mappings,
    :single_column_amount_mapping,
    to: :transaction_import,
  )

  def initialize(row:, transaction_import:)
    @row = row
    @transaction_import = transaction_import
  end

  def account_credited
    if amount_mapping_type == 'single_column'
      if signed_amount_is_credit?
        importing_account
      end
    else
      importing_account if separate_amount_credit.present?
    end
  end

  def account_debited
    if amount_mapping_type == 'single_column'
      if signed_amount_is_debit?
        importing_account
      end
    else
      importing_account if separate_amount_debit.present?
    end
  end

  def amount
    amount_string = if amount_mapping_type == 'single_column'
                      row.fetch(column_mapping_index('combined_amount'), 0)
                    else
                      separate_amount_credit ||
                        separate_amount_debit ||
                        0
                    end

    parse_amount(amount_string)
  end

  def date
    parse_date(date: row.fetch(column_mapping_index('date'), nil))
  end

  def memo
    row.fetch(column_mapping_index('memo'), nil)
  end

  private

  def column_mapping_index(search_value)
    column_mappings.find_index(search_value)
  end

  def importing_account
    @importing_account ||= Account.find(transaction_import.importing_account)
  end

  def parse_amount(amount_string)
    amount_string.gsub!('$', '')
    parenthesis_as_neg = Regexp.new(/\((\d*\.?\d*)\)/)
    if parenthesis_as_neg.match?(amount_string)
      amount_string = '-' + parenthesis_as_neg.match(amount_string)[1]
    end
    BigDecimal(amount_string).round(2)
  end

  def parse_date(date:)
    parse_date_mdy(date: date) ||
      parse_date_ymd(date: date)
  end

  def parse_date_mdy(date:)
    ::Date.strptime(date, '%m/%d/%Y')
  rescue ::Date::Error => e
    nil
  end

  def parse_date_ymd(date:)
    ::Date.strptime(date, '%Y-%m-%d')
  end

  def separate_amount_credit
    row.fetch(column_mapping_index('credit_amount'), nil).presence
  end

  def separate_amount_debit
    row.fetch(column_mapping_index('debit_amount'), nil).presence
  end

  def signed_amount_is_credit?
    (amount >= 0 && single_column_amount_mapping == 'positive_is_credit') ||
      (amount < 0 && single_column_amount_mapping == 'positive_is_debit')
  end

  def signed_amount_is_debit?
    !signed_amount_is_credit?
  end
end
