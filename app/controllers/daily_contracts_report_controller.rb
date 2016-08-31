# Controller for listing DailyContractsReport
class DailyContractsReportController < ApplicationController
  def index
    @report = DailyContractsReport.new(report_params)

    if @report.valid?
      result_parameters
    else
      error_respond
    end
  end

  private

  # strong parameters
  def report_params
    if params[:contracts_date]
      params.permit(:contracts_date).require(:contracts_date)
    end
  end

  def result_parameters
    @contracts_date  = @report.contracts_date
    @contracts_list  = @report.contracts_list
    @contracts_total = @report.contracts_total
  end

  def error_respond
    respond_to do |format|
      format.html do
        redirect_to menu_path, alert: @report.errors.full_messages
      end
    end
  end
end
