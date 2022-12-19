# frozen_string_literal: true

class TransactionImportsController < ApplicationController
  def index
    @transaction_imports = TransactionImport.all.reorder(:created_at)
  end

  def new
    @transaction_import_form = ::TransactionImportForm.new({})
  end

  def create
    @transaction_import_form = ::TransactionImportForm.new(allowed_new_params)
    if @transaction_import_form.save
      redirect_to transaction_imports_path, notice: 'Transaction created'
    else
      render :new
    end
  end

  def edit
    @transaction_import = TransactionImport.find(params.fetch(:id))
    @transaction_import_process_form = ::TransactionImportProcessForm.new(@transaction_import)
  end

  def update
    @transaction_import = TransactionImport.find(params.fetch(:id))
    @transaction_import_process_form = ::TransactionImportProcessForm.new(
      @transaction_import,
      allowed_processing_params,
    )
    if @transaction_import_process_form.save
      redirect_to transaction_imports_path, notice: 'Successfully started import process'
    else
      render :edit, alert: 'Please review the errors and adjust accordingly'
    end
  end

  private

  def allowed_new_params
    params.require(:transaction_import_form).permit(:import_csv, :name)
  end

  def allowed_processing_params
    params.require(:transaction_import_process_form).permit(
      :amount_mapping_type,
      :importing_account,
      :single_column_amount_mapping,

      column_mappings: [],
    )
  end
end
