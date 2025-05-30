# test_data.rb

# Crear usuarios
User.create(dni: "12345678", name: "Juan", surname: "Peña", address: "Calle falsa 123", email: "juan@yahoo.com", date_of_birth: "1990-01-01")
User.create(dni: "87654321", name: "Ana", surname: "Gómez", address: "Av. Siempreviva 742", email: "ana.gomez@example.com", date_of_birth: "1992-07-15")

# Crear cuentas
juan_account = Account.create(dni_owner: "12345678", password_digest: "supersecreta123", balance: 10000, status_active: true)
ana_account  = Account.create(dni_owner: "87654321", password_digest: "supersecreta123", balance: 10000, status_active: true)

# Crear transacción
Transaction.create(source_cvu: Account.find_by(dni_owner: "12345678").cvu, destination_cvu: Account.find_by(dni_owner: "87654321").cvu, amount: 2500, details: "Transferencia entre Juan y Ana", status: "completed")

#Transaccion solo dsps de crear un usuario a travez de la web
#Transaction.create(source_cvu: Account.find_by(dni_owner: "87654321").cvu, destination_cvu: Account.find_by(dni_owner: "12333456").cvu, amount: 2500, details: "Transferencia entre Ana y Mat", status: "completed")

puts "Datos de prueba cargados correctamente."

# Mostar la transacción

Transaction.all
