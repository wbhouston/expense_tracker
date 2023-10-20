# frozen_string_literal: true

module Reports
  module Charts
    class CashFlowsController < ApplicationController
      def show
        @view_object = ::Reports::Charts::CashFlowsPresenter.new
      end
    end
  end
end