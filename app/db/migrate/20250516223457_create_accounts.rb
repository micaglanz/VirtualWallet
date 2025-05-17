class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts, id false do |t|
      t.references :user, null: false, foreign_key: { to_table:users, primary_key: :DNI}
      t.string :password, null: false
      t.integer :balance, null: false, default: 0
      t.boolean :status_active, default: true
      t.string :cvu, null: false, primary_key: true
      t.string :alias, null: false, unique: true    
    end
    add_index :accounts, :alias
  end
end
