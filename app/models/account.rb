class Account < ActiveRecord::Base
  
 
  self.primary_key = 'cvu'

  #Relationships
  belongs_to :user, foreign_key: :dni_owner, primary_key: :dni, inverse_of: :accounts

  has_one :card, foreign_key: 'account_cvu', primary_key: 'cvu', inverse_of: :account, dependent: :destroy

  has_many :transactions_done, class_name: 'Transaction', foreign_key: 'cvu', dependent: :nullify
  has_many :transactios_recieved, class_name: 'Transaction', foreign_key: 'cvu', dependent: :nullify
  
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
end