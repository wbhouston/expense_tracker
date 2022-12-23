# frozen_string_literal: true

class MergedTransaction < Transaction
  before_validation :update_status_to_merged

  def active?
    false
  end

  private

  def update_status_to_merged
    self.status = 'merged'
  end
end
