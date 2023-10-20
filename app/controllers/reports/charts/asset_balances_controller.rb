
# frozen_string_literal: true

module Reports
  module Charts
    class AssetBalancesController < ApplicationController
      def show
        @view_object = ::Reports::Charts::AssetBalancesPresenter.new
      end
    end
  end
end