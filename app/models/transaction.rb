class Transaction < ActiveRecord::Base
    
    TRANSACTION_STATUS = {
        pending:    'pending',
        completed:  'completed',
        failed:     'failed'
    }

    def pending?
        status == TRANSACTION_STATUS[:pending]
    end

    def completed?
        status == TRANSACTION_STATUS[:completed]
    end

    def failed?
        status == TRANSACTION_STATUS[:failed]
    end

    def cancelled?
        status == TRANSACTION_STATUS[:cancelled]
    end
    
    belongs_to :source_account, class_name: 'Account', foreign_key: 'source_cvu', primary_key: 'cvu'
    belongs_to :destination_account, class_name: 'Account', foreign_key: 'destination_cvu', primary_key: 'cvu'
    #Relationships

    #Validations
    validates :id, presence: true
    validates :source_cvu, presence: true
    validates :destination_cvu, presence: true
    validates :amount, presence: true, numericality: { greater_than: 0 }
    validates :date, presence: true
    validates :details,
    validates :status, presence: true, inclusion: { in: TRANSACTION_STATUS.values }

    validate :active_account

    private

    def active_account
        unless account&.status_active?
        errors.add(:account, "debe estar activa para realizar transacciones")
        end
    end

end