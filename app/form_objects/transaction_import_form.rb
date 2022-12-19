# frozen_string_literal: true

require 'csv'

class TransactionImportForm
  include ::ActiveModel::Model

  attr_reader :parsed_csv, :transaction_import

  delegate(
    :import_csv,
    :name,
    :name=,
    to: :transaction_import
  )

  validates(:parsed_csv, :name, presence: true)

  def initialize(params)
    @transaction_import = TransactionImport.new
    super(params)
  end

  def import_csv=(file)
    transaction_import.import_csv = file
    @parsed_csv = CSV.read(file)
  end

  def save
    if valid?
      TransactionImport.transaction do
        @transaction_import.save!
        @transaction_import.parsed_csv_cache = parsed_csv
      end

      true
    else
      false
    end
  end
end
