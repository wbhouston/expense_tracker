# frozen_string_literal: true

class TransactionImport < ApplicationRecord
  include ::Redis::Objects

  IMPORTED_COLUMNS = %w(
    combined_amount
    credit_amount
    debit_amount
    date
    imported_transaction_id
    memo
  ).freeze

  IMPORTING_ACCOUNT_MAPPING_TYPES = %w(separate_columns single_column).freeze

  IMPORTING_ACCOUNT_SINGLE_COLUMN_MAPPING = %w(
    positive_is_credit
    positive_is_debit
  ).freeze

  list :column_mappings, marshal: true
  list :parsed_csv, marshal: true

  value :amount_mapping_type_value
  value :importing_account_value
  value :single_column_amount_mapping_value

  def amount_mapping_type
    amount_mapping_type_value.value
  end

  def amount_mapping_type=(val)
    amount_mapping_type_value.value = val
  end

  def importing_account
    importing_account_value.value
  end

  def importing_account=(val)
    importing_account_value.value = val
  end

  def single_column_amount_mapping
    single_column_amount_mapping_value.value
  end

  def single_column_amount_mapping=(val)
    single_column_amount_mapping_value.value = val
  end
end
