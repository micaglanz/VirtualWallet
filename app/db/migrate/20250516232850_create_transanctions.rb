class CreateTransanctions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :source, null: false, foreign_key: { to_table:accounts, primary_key: :cvu}
      t.references :destination, null: false, foreign_key: { to_table:accounts, primary_key: :cvu}
      t.timestamps :date
      t.string :detail
      t.integer :amount, null: false
      t.TRANSACTION_STATUS :status, null: false
    end
    add_index :transactions, :date
  end
end
