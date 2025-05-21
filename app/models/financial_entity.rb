class FinancialEntity < ActiveRecord::Base

  has_one :account, dependent: :destroy, inverse_of: :financial_entity

  validates :name, presence: true, uniqueness: true
  validates :address, presence: true
end
