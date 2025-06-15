class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    unless table_exists?(:users)
      create_table :users, id: false, primary_key: :dni do |t|
        t.string :dni, null: false
        t.string :name, null: false
        t.string :surname, null: false
        t.string :address, null: false
        t.string :email, null: false
        t.string :password_digest, null: false
        t.date :date_of_birth, null: false
        t.timestamps
      end

      add_index :users, :email, unique: true
    end

  end

end
