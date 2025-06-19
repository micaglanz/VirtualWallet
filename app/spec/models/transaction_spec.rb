require_relative '../spec_helper'

RSpec.describe Transaction do
    roberto = User.create(
    dni: "54789123",
    name: "Roberto",
    surname: "Juarez",
    address: "Calle falsa 123",
    email: "roberto.j@yahoo.com",
    password: "supersecreta123",
    password_confirmation: "supersecreta123",
    date_of_birth: "1990-01-01"
  )
    florencia = User.create(
    dni: "98765432",
    name: "Florencia",
    surname: "Peña",
    address: "Calle falsa 123",
    email: "florenciap@yahoo.com",
    password: "supersecreta123",
    password_confirmation: "supersecreta123",
    date_of_birth: "1990-01-01"
  )

  let(:source_cvu) { Account.create!(dni_owner: roberto.dni, balance: 100, status_active: true) }
  let(:destination_cvu) { Account.create!(dni_owner: florencia.dni, balance: 50, status_active: true) }

  context 'validations' do
    it 'no permite crear transacción si no hay saldo suficiente' do
      transaction = Transaction.new(
        source_cvu: source_cvu.cvu,
        destination_cvu: destination_cvu.cvu,
        amount: 150
      )
      expect(transaction).not_to be_valid
      expect(transaction.errors[:amount]).to include("Saldo insuficiente en la cuenta origen")
    end

    it 'permite crear transacción si hay saldo suficiente' do
      transaction = Transaction.new(
        source_cvu: source_cvu.cvu,
        destination_cvu: destination_cvu.cvu,
        details: 'hay saldo suficiente TEST',
        amount: 50
      )
      expect(transaction).to be_valid
    end
  end

  context 'after create callback' do
    it 'debita y acredita los balances correctamente' do
      transaction = Transaction.create!(
        source_cvu: source_cvu.cvu,
        destination_cvu: destination_cvu.cvu,
        details: 'debita y acredita los balances correctamente TEST',
        amount: 40
      )

      expect(source_cvu.reload.balance).to eq(60)
      expect(destination_cvu.reload.balance).to eq(90)
    end
  end
end