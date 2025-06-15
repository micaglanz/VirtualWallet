# test_data.rb

# Crear usuarios
User.create(dni: "12345678", name: "Juan", surname: "Peña", address: "Calle falsa 123", email: "juan@yahoo.com", password: "supersecreta123", password_confirmation: "supersecreta123", date_of_birth: "1990-01-01")
User.create(dni: "87654321", name: "Ana", surname: "Gómez", address: "Av. Siempreviva 742", email: "ana.gomez@example.com", password: "supersecreta123", password_confirmation: "supersecreta123", date_of_birth: "1992-07-15")

# Crear cuentas
juan_account = Account.create(dni_owner: "12345678",  balance: 10000, status_active: true)
ana_account  = Account.create(dni_owner: "87654321",  balance: 10000, status_active: true)

# Crear transacción
Transaction.create(source_cvu: Account.find_by(dni_owner: "12345678").cvu, destination_cvu: Account.find_by(dni_owner: "87654321").cvu, amount: 2500, details: "Transferencia entre Juan y Ana", status: "completed")
Transaction.create(source_cvu: Account.find_by(dni_owner: "12333456").cvu, destination_cvu: Account.find_by(dni_owner: "12345678").cvu, amount: 200, details: "Transferencia entre Cavi y Juan")


juan_card = Card.create( responsible_name: "Juan Pérez", expire_date: Date.new(2026, 12, 31), service: :visa, account_cvu: "12345678", card_number: "3000000000000003")
ana_card = Card.create( responsible_name: "Ana Gomez", expire_date: Date.new(2026, 06, 30), service: :mastercard, account_cvu: "87654321", card_number: "4444444444444444")

#Transaccion solo dsps de crear un usuario a travez de la web
#Transaction.create(source_cvu: Account.find_by(dni_owner: "87654321").cvu, destination_cvu: Account.find_by(dni_owner: "12333456").cvu, amount: 2500, details: "Transferencia entre Ana y Mat", status: "completed")

puts "Datos de prueba cargados correctamente."

# Mostar la transacción

Transaction.all
