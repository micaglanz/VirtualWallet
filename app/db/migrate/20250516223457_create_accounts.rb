class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    unless table_exists?(:accounts)
      create_table :accounts, id: false, primary_key: :cvu do |t|
        t.string :cvu, null: false
        t.string :dni_owner, null: false
        t.integer :balance, null: false, default: 0
        t.boolean :status_active, default: true
        t.string :alias, null: false
        t.timestamps
      end
    end

    add_index :accounts, :alias, unique: true
    add_index :accounts, :cvu, unique: true
    add_index :users, :dni, unique: true
    add_foreign_key :accounts, :users, column: :dni_owner, primary_key: :dni
  end
end

