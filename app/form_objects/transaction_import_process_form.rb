# frozen_string_literal: true

require 'csv'

class TransactionImportProcessForm
  include ::ActiveModel::Model

  attr_accessor(:importing_account)

  attr_reader(:transaction_import)

  delegate(
    :amount_mapping_type,
    :amount_mapping_type=,
    :column_mappings,
    :column_mappings=,
    :importing_account,
    :importing_account=,
    :parsed_csv,
    :single_column_amount_mapping,
    :single_column_amount_mapping=,
    to: :transaction_import,
  )

  validate :absence_of_alternate_column_mappings
  validate :presence_of_amount_columns
  validate :presence_of_date_mapping

  validates(
    :amount_mapping_type,
    :importing_account,
    presence: true,
  )

  validates(
    :single_column_amount_mapping,
    presence: true,
    if: :single_column_amount?
  )

  def initialize(transaction_import, params = {})
    @column_mappings ||= []
    @transaction_import = transaction_import
    super(params)
  end

  def save
    if valid?
      ::Services::ImportTransactionsWorker.perform_async(transaction_import.id)
    else
      false
    end
  end

  def column_count
    headers.size
  end

  def headers
    parsed_csv[0]
  end

  def previewed_rows
    parsed_csv[1..6]
  end

  def single_column_amount?
    amount_mapping_type == 'single_column'
  end

  private

  def absence_of_alternate_column_mappings
    if single_column_amount?
      alternates = column_mappings.value & required_mappings_for_separate_columns
      if alternates.present?
        errors.add(
          :base,
          'With single column mapping, only combined_amount must be mapped',
        )
      end
    else
      alternates = column_mappings.value & required_mappings_for_single_column
      if alternates.present?
        errors.add(
          :base,
          'With separate column mappings, combined amount column must not be mapped',
        )
      end
    end
  end

  def presence_of_amount_columns
    if single_column_amount?
      required_mappings = column_mappings.value & required_mappings_for_single_column
      unless required_mappings.eql?(required_mappings_for_single_column)
        errors.add(
          :base,
          'With single column mapping, combined_amount must be mapped',
        )
      end
    else
      required_mappings = column_mappings.value & required_mappings_for_separate_columns
      unless required_mappings.sort.eql?(required_mappings_for_separate_columns.sort)
        errors.add(
          :base,
          'With separate column mappings, credit and debit columns must be mapped',
        )
      end
    end
  end

  def presence_of_date_mapping
    unless column_mappings.include?('date')
      errors.add(
        :base,
        'The date column must be mapped',
      )
    end
  end

  def required_mappings_for_separate_columns
    ['credit_amount', 'debit_amount']
  end

  def required_mappings_for_single_column
    ['combined_amount']
  end
end
