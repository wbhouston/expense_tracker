# frozen_string_literal: true

module Reports
  module Charts
    class ProjectedExpensesController < ApplicationController
      def show
        @view_object = ::Reports::Charts::ProjectedExpensesPresenter.new
      end
    end
  end
end