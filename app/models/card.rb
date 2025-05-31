class Card < ActiveRecord::Base
  #Relationships
  belongs_to :account, foreign_key: 'account_cvu', primary_key: 'cvu', inverse_of: :cards
  has_many :transactions, foreign_key: 'card_id', dependent: :nullify

  #Enumerations 
  #enum service: { mastercard: 0, visa: 1 }
  SERVICE_VALUES = {mastercard: 0, visa: 1}

  validates :service, inclusion: {in: SERVICE_VALUES.values}

  def service_name
    SERVICE_VALUES.key(self.service).to_s
  end

  def service=(value)
    if value.is_a?(Integer)
      super(value)
    else
      super(SERVICE_VALUES[value.to_sym])
    end
  end

  def visa?
    service == SERVICE_VALUES[:visa]
  end

  def mastercard?
    service == SERVICE_VALUES[:mastercard]
  end


  #Validations
  validates :responsible_name, presence: true
  validates :expire_date, presence: true
  validate  :expire_date_cannot_be_in_the_past
  validates :service, presence: true
  validates :card_number, presence: true, uniqueness: true

  private

  def expire_date_cannot_be_in_the_past
    if expire_date.present? && expire_date < Date.today
      errors.add(:expire_date, "no puede estar vencida")
    end
  end
end

