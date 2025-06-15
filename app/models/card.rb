class Card < ActiveRecord::Base
  # Relationships
  belongs_to :account, foreign_key: 'account_cvu', primary_key: 'cvu', inverse_of: :card

  # Enumerations 
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

  # Validations
  validates :responsible_name, presence: true
  validates :expire_date, presence: true
  validate  :expire_date_cannot_be_in_the_past
  validates :service, presence: true
  validates :card_number, presence: true, uniqueness: true

  # Callback para generar card_number antes de validar (antes de crear)
  before_validation :generate_card_number, on: :create

  private

  def expire_date_cannot_be_in_the_past
    if expire_date.present? && expire_date < Date.today
      errors.add(:expire_date, "no puede estar vencida")
    end
  end

  def generate_card_number
    return if card_number.present?

    loop do
      # Genera un número aleatorio de 16 dígitos (string)
      random_number = 16.times.map { rand(0..9) }.join
      # Si no existe otra tarjeta con ese número, asignalo y salí
      unless Card.exists?(card_number: random_number)
        self.card_number = random_number
        break
      end
    end
  end
end


