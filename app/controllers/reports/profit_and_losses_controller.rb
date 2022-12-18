# frozen_string_literal: true

module Reports
  class ProfitAndLossesController < ApplicationController
    def index
      @report = ::Reports::ProfitAndLosses.new
    end
  end
end
