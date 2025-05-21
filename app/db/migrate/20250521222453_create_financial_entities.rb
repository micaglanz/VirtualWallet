class CreateFinancialEntities < ActiveRecord::Migration[6.1]
  def change
    create_table :financial_entities do |t|
      t.string :name, null: false
      t.string :entity_type
      t.string :currency
      t.timestamps
    end
  end
end
