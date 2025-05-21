class card < ApplicationRecord
  #Relationships
  belongs_to :account, foreign_key: 'account_cvu', primary_key: 'cvu', inverse_of: :cards
  has_many :transactions, foreign_key: 'card_id', dependent: :nullify

  #Enumerations 
  enum service: { mastercard: 0, visa: 1 }

  #Validations
  validates :responsible_name, presence: true
  validates :expire_date, presence: true
  validate  :expire_date_cannot_be_in_the_past
  validates :service, presence: true

  private

  def expire_date_cannot_be_in_the_past
    if expire_date.present? && expire_date < Date.today
      errors.add(:expire_date, "no puede estar vencida")
    end
  end
end

