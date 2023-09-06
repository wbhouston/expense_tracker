# frozen_string_literal: true

class MergedTransaction < Transaction
  before_validation :update_status_to_inactive

  private

  def update_status_to_inactive
    self.status = 'inactive'
  end
end
