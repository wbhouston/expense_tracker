# frozen_string_literal: true

require 'csv'

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

  has_one_attached :import_csv

  list :column_mappings, marshal: true
  list :parsed_csv_cache, marshal: true, expire: 1.day

  value :amount_mapping_type_value
  value :importing_account_value
  value :single_column_amount_mapping_value

  def amount_mapping_type
    amount_mapping_type_value.value
  end

  def amount_mapping_type=(val)
    amount_mapping_type_value.value = val
  end

  def parsed_csv
    @parsed_csv ||= if parsed_csv_cache.value.present?
                      parsed_csv_cache.value
                    else
                      parsed_csv_cache = CSV.parse(import_csv.download)
                    end
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
