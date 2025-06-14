class CreateFinancialEntities < ActiveRecord::Migration[8.0]
  def change
    create_table :financial_entities do |t|
      t.string :name, null: false
      t.string :account_cvu, null: false
      t.timestamps
    end

    add_index :financial_entities, :account_cvu
    add_foreign_key :financial_entities, :accounts, column: :account_cvu, primary_key: :cvu
  end
end
