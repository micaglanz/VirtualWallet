class CreateFinancialEntities < ActiveRecord::Migration[8.0]
  def change
    create_table :financial_entities do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end
