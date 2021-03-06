class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.references :leaf, index: true, foreign_key: true
      t.string :first_name, limit: 10, null: false
      t.string :last_name, limit: 10, null: false
      t.string :first_read, limit: 20, null: false
      t.string :last_read, limit: 20, null: false
      t.boolean :sex, null: false
      t.string :address, limit: 50, null: false
      t.string :phone_number, limit: 12
      t.string :cell_number, limit: 13
      t.string :receipt, limit: 50, null: false
      t.string :comment, limit: 100, null: false

      t.timestamps null: false
    end
  end
end
