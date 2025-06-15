class Transaction < ActiveRecord::Base
  TRANSACTION_STATUS = {
    pending:    'pending',
    completed:  'completed',
    failed:     'failed',
  }

  before_create :set_status_pending
  after_create :transfer_balance_and_update_status

  belongs_to :source_account, class_name: 'Account', foreign_key: :source_cvu, primary_key: :cvu, optional: true
  belongs_to :destination_account, class_name: 'Account', foreign_key: :destination_cvu, primary_key: :cvu, optional: true


  validates :source_cvu, presence: true, on: :create
  validates :destination_cvu, presence: true, on: :create

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :details, presence: true

  validate :active_account
  validate :sufficient_balance

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
    if source_account.nil? || !source_account.status_active?
      errors.add(:source_account, "debe estar activa para realizar transacciones")
    end

    if destination_account.nil? || !destination_account.status_active?
      errors.add(:destination_account, "debe estar activa para realizar transacciones")
    end
  end

  def sufficient_balance
    if source_account && source_account.balance < amount
      errors.add(:amount, "Saldo insuficiente en la cuenta origen")
    end
  end

  def transfer_balance_and_update_status
    begin
      ActiveRecord::Base.transaction do
        source_account.balance -= amount
        source_account.save!

        destination_account.balance += amount
        destination_account.save!
      end
      update_column(:status, TRANSACTION_STATUS[:completed])
    rescue StandardError => e
      update_column(:status, TRANSACTION_STATUS[:failed])
      logger.error("Falló la transferencia: #{e.message}")
    end
  end
end
