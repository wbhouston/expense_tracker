# frozen_string_literal: true

class MergedTransaction < Transaction
  def active?
    false
  end
end
