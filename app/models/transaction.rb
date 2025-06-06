class Transaction < ActiveRecord::Base
  TRANSACTION_STATUS = {
    pending:    'pending',
    completed:  'completed',
    failed:     'failed',
  }

  before_create :set_status_pending

  after_create :transfer_balance_and_update_status

  # Relaciones y validaciones como antes
  belongs_to :account, foreign_key: :source_cvu, primary_key: :cvu

  validates :source_cvu, presence: true
  validates :destination_cvu, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :details, presence: true
  # Ya no validamos status porque es interno

  validate :active_account

  def pending?
    status == TRANSACTION_STATUS[:pending]
  end

  def completed?
    status == TRANSACTION_STATUS[:completed]
  end

  def failed?
    status == TRANSACTION_STATUS[:failed]
  end

  private

  def set_status_pending
    self.status = TRANSACTION_STATUS[:pending]
  end

  def active_account
    unless account&.status_active?
      errors.add(:account, "debe estar activa para realizar transacciones")
    end
  end

  def transfer_balance_and_update_status
    source_account = Account.find_by(cvu: source_cvu)
    target_account = Account.find_by(cvu: destination_cvu)

    begin
      ActiveRecord::Base.transaction do
        source_account.balance -= amount
        source_account.save!

        target_account.balance += amount
        target_account.save!
      end
      update_column(:status, TRANSACTION_STATUS[:completed])
    rescue StandardError => e
      update_column(:status, TRANSACTION_STATUS[:failed])
      # Opcional: loguear el error
      logger.error("Falló la transferencia: #{e.message}")
    end
  end

  validate :sufficient_balance

  def sufficient_balance
   source_account = Account.find_by(cvu: source_cvu)
   if source_account && source_account.balance < amount
     errors.add(:amount, "Saldo insuficiente en la cuenta origen")
   end
  end

end
