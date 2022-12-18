# frozen_string_literal: true

class MergeAccountsForm
  include ::ActiveModel::Model

  attr_accessor :merge_account_ids, :merge_into_id

  validates(
    :merge_account_ids,
    :merge_into_id,
    presence: true,
  )

  def initialize(merge_account_ids:, merge_into_id:)
    @merge_account_ids = merge_account_ids.compact
    @merge_into_id = merge_into_id
    @merge_account_ids.delete(@merge_into_id) if @merge_into_id.present?
  end

  def perform
    if valid?
      ::Services::MergeAccountsWorker.perform_async(
        merge_into_id,
        merge_account_ids,
      )

      true
    else
      false
    end
  end
end
