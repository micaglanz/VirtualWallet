class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.string :source_cvu, null: true
      t.string :destination_cvu, null: true
      t.string :details
      t.integer :amount, null: false
      t.string :status, null: false
      t.timestamps
    end



    add_foreign_key :transactions, :accounts, column: :source_cvu, primary_key: :cvu, on_delete: :nullify
    add_foreign_key :transactions, :accounts, column: :destination_cvu, primary_key: :cvu, on_delete: :nullify


    add_index :transactions, :source_cvu, name: "index_trans_source_cvu"
    add_index :transactions, :destination_cvu, name: "index_trans_destination_cvu"
    add_index :transactions, :created_at
  end
end