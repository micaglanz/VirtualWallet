require_relative '../models/user'
require_relative '../models/account'
require_relative '../models/financial_entity'
require_relative '../models/card'
require_relative '../models/transaction'

unless User.exists?(dni: "00000001")
  fe_user = User.new(
    dni: "00000001",
    name: "Banco",
    surname: "Central",
    address: "Oroño 303",
    email: "bancocentral@gov.com.ar",
    password: "default_password",
    password_confirmation: "default_password",
    date_of_birth: Time.current
  )

  if fe_user.save
    fe_account = Account.new(
      dni_owner: fe_user.dni,
      balance: 1_000_000_000,
      status_active: true
    )

    if fe_account.save
      fentity = FinancialEntity.new(
        name: "#{fe_user.name} #{fe_user.surname}",
        account_cvu: fe_account.cvu
      )

      if fentity.save
        puts "Entidad financiera creada correctamente."
      else
        fe_account.destroy
        fe_user.destroy
        puts "No se pudo crear la entidad financiera."
      end
    else
      fe_user.destroy
      puts "No se pudo crear la cuenta bancaria."
    end
  else
    puts "Entidad financiera NO pudo ser creada correctamente."
  end
else
  puts "El usuario del Banco Central ya existe. Seed no se ejecutó."
end


# === Usuario: Juan ===
unless User.exists?(dni: "12345678")
  juan = User.new(
    dni: "12345678",
    name: "Juan",
    surname: "Peña",
    address: "Calle falsa 123",
    email: "juan@yahoo.com",
    password: "supersecreta123",
    password_confirmation: "supersecreta123",
    date_of_birth: "1990-01-01"
  )

  if juan.save
    juan_account = Account.new(dni_owner: juan.dni, balance: 10000, status_active: true)

    if juan_account.save
      card = Card.new(
        responsible_name: "Juan Pérez",
        expire_date: Date.today.next_year(5),
        service: :visa,
        account_cvu: juan_account.cvu,
        card_number: "3000000000000003"
      )

      if card.save
        puts "Usuario Juan creado correctamente con su cuenta y tarjeta."
      else
        juan_account.destroy
        juan.destroy
        puts "Error al crear la tarjeta de Juan. Se deshizo la creación."
      end
    else
      juan.destroy
      puts "Error al crear la cuenta de Juan."
    end
  else
    puts "Error al crear el usuario Juan: #{juan.errors.full_messages.join(', ')}"
  end
else
  puts "El usuario Juan ya existe. Seed no se ejecutó."
end

# === Usuario: Ana ===
unless User.exists?(dni: "87654321")
  ana = User.new(
    dni: "87654321",
    name: "Ana",
    surname: "Gómez",
    address: "Av. Siempreviva 742",
    email: "ana.gomez@example.com",
    password: "supersecreta123",
    password_confirmation: "supersecreta123",
    date_of_birth: "1992-07-15"
  )

  if ana.save
    ana_account = Account.new(dni_owner: ana.dni, balance: 10000, status_active: true)

    if ana_account.save
      card = Card.new(
        responsible_name: "Ana Gomez",
        expire_date: Date.today.next_year(5),
        service: :mastercard,
        account_cvu: ana_account.cvu,
        card_number: "4444444444444444"
      )

      if card.save
        puts "Usuario Ana creado correctamente con su cuenta y tarjeta."
      else
        ana_account.destroy
        ana.destroy
        puts "Error al crear la tarjeta de Ana. Se deshizo la creación."
      end
    else
      ana.destroy
      puts "Error al crear la cuenta de Ana."
    end
  else
    puts "Error al crear el usuario Ana: #{ana.errors.full_messages.join(', ')}"
  end
else
  puts "El usuario Ana ya existe. Seed no se ejecutó."
end

# === Transacción entre Juan y Ana ===
juan_account = Account.find_by(dni_owner: "12345678")
ana_account  = Account.find_by(dni_owner: "87654321")

if juan_account && ana_account
  unless Transaction.exists?(source_cvu: juan_account.cvu, destination_cvu: ana_account.cvu, amount: 2500)
    Transaction.create!(
      source_cvu: juan_account.cvu,
      destination_cvu: ana_account.cvu,
      amount: 2500,
      details: "Transferencia entre Juan y Ana",
    )
    puts "Transacción entre Juan y Ana creada correctamente."
  else
    puts "La transacción entre Juan y Ana ya existe. Seed no se ejecutó."
  end
else
  puts "No se pudo crear la transacción porque no existen ambas cuentas."
end

