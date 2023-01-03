# frozen_string_literal: true

module Reports
  class ProfitAndLossesController < ApplicationController
    def index
      @report = ::Reports::ProfitAndLosses.new(year: search_year)
    end

    private

    def search_year
      params.fetch(:search, {}).fetch(:year, Date.current.year).to_i
    end
  end
end
