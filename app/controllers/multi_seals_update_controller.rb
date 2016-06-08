class MultiSealsUpdateController < ApplicationController
  def index
    @query = Leaf.ransack(ransack_params)

    numbers_sealsid_list =  @query.result.includes(:contracts).
                            select( 'number, seals.id as seal_id')

    @unsealed_list = UpdateMultiSeals.new(
      numbers_sealsid_list: numbers_sealsid_list,
      sealed_date: Date.current,
      staff_nickname: session[:nickname]
    )
  end

  def update
    @unsealed_list = UpdateMultiSeals.new(update_params)
    
    respond_to do |format|
      if @unsealed_list.updateSelectedSeals
        format.html { redirect_to menu_path,
                      notice: 'シール情報を更新しました。' }
        format.json { render :index, status: :ok,
                      location: multi_seals_update_path }
      else
        format.html { redirect_to menu_path,
                      notice: @unsealed_list.errors.full_messages }
        format.json { render json: errors,
                      status: :unprocessable_entity }
      end
    end
  end
  
  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def ransack_params
    # Get method has no params, so fixed conditions are set.
    if params[:q].nil?
      params[:q] = {
        "contracts_seals_month_eq" => Date.current.next_month.beginning_of_month,
        "vhiecle_type_eq" => 1,
        "valid_flag" => true,
        "contracts_seals_sealed_flag_eq" => false
      }
    else
      # Seals' months are the day beginning of month
      # "2016-05" => "2016-05-01"
      params[:q][:contracts_seals_month_eq].concat("-01")

      params.require(:q)
      .permit(
        :vhiecle_type_eq,
        :valid_flag_eq,
        :contracts_seals_month_eq,
        :contracts_seals_sealed_flag_eq
      )
    end
  end

  def update_params
    params.require(:update_multi_seals)
      .permit(
        :staff_nickname,
        :sealed_date,
        numbers_sealsid_list: []
      )
  end
end
