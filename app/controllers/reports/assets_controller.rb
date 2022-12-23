# frozen_string_literal: true

module Reports
  class AssetsController < ApplicationController
    def index
      @report = ::Reports::Assets.new
    end
  end
end
