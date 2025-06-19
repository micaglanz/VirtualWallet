require_relative '../spec_helper'

RSpec.describe Transaction do
  let(:source_cvu) { Account.find_by(dni_owner:"12345678").cvu}
  let(:destination_cvu) { Account.find_by(dni_owner:"87654321").cvu }

  context 'validations' do
    it 'no permite crear transacción si no hay saldo suficiente' do
      transaction = Transaction.new(
        source_cvu: source_cvu,
        destination_cvu: destination_cvu,
        amount: 150
      )
      expect(transaction).not_to be_valid
      expect(transaction.errors[:base]).to include("No hay saldo suficiente en la cuenta origen para esta transacción")
    end

    it 'permite crear transacción si hay saldo suficiente' do
      transaction = Transaction.new(
        source_cvu: source_cvu,
        destination_cvu: destination_cvu,
        amount: 50
      )
      expect(transaction).to be_valid
    end
  end

  context 'after create callback' do
    it 'debita y acredita los balances correctamente' do
      transaction = Transaction.create!(
        source_cvu: source_cvu,
        destination_cvu: destination_cvu,
        amount: 40
      )

      expect(source_cvu.reload.balance).to eq(60)
      expect(destination_cvu.reload.balance).to eq(90)
    end
  end
end
