class AddIndexToStaff < ActiveRecord::Migration
  def change
    add_index :staffs, :nickname

  end
end
