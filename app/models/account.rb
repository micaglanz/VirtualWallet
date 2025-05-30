class Account < ActiveRecord::Base
  
    #Authentication
    has_secure_password
    
    self.primary_key = 'cvu'

    #Relationships
    belongs_to :user, foreign_key: :dni_owner, primary_key: :dni, inverse_of: :account

    has_many :cards, foreign_key: 'account_cvu', primary_key: 'cvu', dependent: :destroy
    has_many :transactions_done, class_name: 'Transaction', foreign_key: 'cvu', dependent: :nullify
    has_many :transactios_recived, class_name: 'Transaction', foreign_key: 'cvu', dependent: :nullify
    
    #Validations
    validates :cvu, presence: true, uniqueness: true
    validates :alias, presence: true
    validates :balance, presence: true, numericality: {  greater_than_or_equal_to: 0 }
    validates :status_active, presence: true, inclusion: { in: [true, false] }

    # Callbacks
  before_validation :generate_unique_cvu, on: :create

  private

  def generate_unique_cvu
    return if self.cvu.present?

    loop do
      self.cvu = Array.new(22) { rand(0..9) }.join
      break unless Account.exists?(cvu: self.cvu)
    end
  end

  before_validation :generate_unique_alias, on: :create

  def generate_unique_alias
    words = %w[sol luna rio mar monte fuego tierra aire nube gato perro pez ave hoja flor roca viento]
    loop do
#     generated = "#{SecureRandom.hex(2)}.#{SecureRandom.hex(2)}.#{SecureRandom.hex(2)}"
        generated = [
          words.sample,
          words.sample,
          words.sample
        ].join('.')

      unless Account.exists?(alias: generated)
        self.alias = generated
        break
      end
    end
  end

  # Validar que password y password_confirmation coincidan (opcional, pero recomendado)
  validate :password_confirmation_matches

  def password_confirmation_matches
    if password != password_confirmation
      errors.add(:password_confirmation, "no coincide con la contraseña")
    end
  end

  #Cards
=begin
  after_commit :create_card_with_defaults, on: :create

  private

  def create_card_with_defaults
    responsible = user&.name || "Desconocido"
    self.cards.create!(
      responsible_name: responsible,
      service: :visa,
      expire_date: 5.years.from_now.to_date,
      card_number: generate_unique_card_number
    )
  end

  def generate_unique_card_number
    loop do
      number = Array.new(16) { rand(0..9) }.join
      break number unless Card.exists?(card_number: number)
    end
  end
=end

end