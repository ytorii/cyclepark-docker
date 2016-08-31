# Controller for list CountContractsSummary.
class CountContractsSummaryController < ApplicationController
  include SessionAction

  # This action is allowed for only admin staffs.
  before_action :check_admin

  def index
    summary = CountContractsSummary.new(count_params)

    if summary.valid?
      @counts = summary.count_contracts_summary
    else
      respond_to do |format|
        format.html do
          redirect_to menu_path, alert: summary.errors.full_messages
        end
      end
    end
  end

  private

  # strong parameters
  def count_params
    params.permit(:count_month).require(:count_month) if params[:count_month]
  end
end
