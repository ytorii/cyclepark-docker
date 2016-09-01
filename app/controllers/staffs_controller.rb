require 'securerandom'

# Controller for Staff
class StaffsController < ApplicationController
  include SessionAction

  CREATE_SUCCESS = 'スタッフ情報を登録しました。'.freeze
  UPDATE_SUCCESS = 'スタッフ情報を更新しました。'.freeze
  DELETE_SUCCESS = 'スタッフ情報を削除しました。'.freeze

  # Staff actions are allowed for only admin staffs.
  before_action :check_admin
  before_action :set_staff, only: [:show, :edit, :update, :destroy]

  # GET /staffs
  # GET /staffs.json
  def index
    @staffs = Staff.all
  end

  # GET /staffs/1
  # GET /staffs/1.json
  def show
  end

  # GET /staffs/new
  def new
    @staff = Staff.new
    @staff.build_staffdetail
  end

  # GET /staffs/1/edit
  def edit
  end

  # POST /staffs
  # POST /staffs.json
  def create
    @staff = Staff.new(staff_params)

    respond_to do |format|
      if @staff.save
        format.html { redirect_to @staff, notice: CREATE_SUCCESS }
        format.json { render :show, status: :created, location: @staff }
      else
        format.html { render :new }
        format.json do
          render json: @staff.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # PATCH/PUT /staffs/1
  # PATCH/PUT /staffs/1.json
  def update
    respond_to do |format|
      if @staff.update(staff_params)
        format.html { redirect_to @staff, notice: UPDATE_SUCCESS }
        format.json { render :show, status: :ok, location: @staff }
      else
        format.html { render :edit }
        format.json do
          render json: @staff.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /staffs/1
  # DELETE /staffs/1.json
  def destroy
    @staff.destroy
    respond_to do |format|
      format.html { redirect_to staffs_url, notice: DELETE_SUCCESS }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_staff
    @staff = Staff.find(params[:id])
  end

  # Never trust parameters from the scary internet,
  # only allow the white list through.
  def staff_params
    params.require(:staff).permit(
      :nickname,
      :password,
      :admin_flag,
      staffdetail_attributes: [
        :id, :name, :read,
        :address, :birthday,
        :phone_number, :cell_number
      ]
    )
  end
end
