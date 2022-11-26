# frozen_string_literal: true

require 'csv'

class TransactionImportForm
  include ::ActiveModel::Model

  attr_reader :csv, :parsed_csv, :transaction_import

  delegate(
    :name,
    :name=,
    to: :transaction_import
  )

  validates(:parsed_csv, :name, presence: true)

  def initialize(params)
    @transaction_import = TransactionImport.new
    super(params)
  end

  def csv=(file)
    @parsed_csv = CSV.read(file)
  end

  def save
    if valid?
      TransactionImport.transaction do
        @transaction_import.save!
        @transaction_import.parsed_csv = parsed_csv
      end

      true
    else
      false
    end
  end
end
