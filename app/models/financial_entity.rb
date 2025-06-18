class FinancialEntity < ActiveRecord::Base
  belongs_to :account, foreign_key: 'account_cvu', primary_key: 'cvu', inverse_of: :financial_entities

  validates :name, presence: true, uniqueness: true

end
