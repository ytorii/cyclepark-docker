class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :check_logined
  before_action :build_ransack_object


  private
  def check_logined
    if session[:staff] then
      begin
        @staff = Staff.find(session[:staff])
      rescue ActiveRecord::RecordNotFound
        reset_session
      end
    end

    unless @staff
      flash[:referer] = request.fullpath
      redirect_to controller: :login, action: :index
    end
  end

  def build_ransack_object
    # Ransack object for searching leafs form in the side bar.
    @query = Leaf.ransack params[:q]
  end
end
