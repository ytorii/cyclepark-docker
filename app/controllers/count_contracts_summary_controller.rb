class CountContractsSummaryController < ApplicationController
  def index
    @counts = CountContractsSummary.new().summary
  end
end
