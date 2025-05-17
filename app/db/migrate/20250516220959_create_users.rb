class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id false do |t|
      t.string :name, null: false
      t.string :surname, null: false 
      t.string :DNI, primary_key: true
      t.string :address, null: false
      t.string :email, null: false
      t.string :date_of_birth, null: false
      t.timestamps :registration_date
    end
    add_index :users, :email, unique: true  
  end
end
