class Account < ActiveRecord::Base

    belongs_to :owner, class_name: 'User', foreign_key: 'dni_owner'
    
    #Relationships
    has_many :transactions_done, class_name: 'Transaction', foreign_key: 'cvu', dependent: :nullify
    has_many :transactios_recived, class_name: 'Transaction', foreign_key: 'cvu', dependent: :nullify
    
    #Validations
    validates :cvu, presence: true, uniqueness: true
    validates :password, presence: true
    validates :alias, presence: true
    validates :balance, presence: true, numericality: {  greater_than_or_equal_to: 0 }
    validates :status_active, presence: true


end