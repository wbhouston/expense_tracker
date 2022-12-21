# frozen_string_literal: true

class MergedTransaction < Transaction
  validates_presence_of :parent_id
end
