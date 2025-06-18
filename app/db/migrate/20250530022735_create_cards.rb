class CreateCards < ActiveRecord::Migration[8.0]
  def change
    create_table :cards do |t|
      t.string :responsible_name, null: false
      t.date :expire_date, null: false
      t.integer :service, null: false
      t.string :account_cvu, null: false
      t.string :card_number, null: false

      t.timestamps
    end

    add_index :cards, :account_cvu
    add_index :cards, :card_number, unique: true
  end
end
