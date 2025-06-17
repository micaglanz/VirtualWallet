require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/reloader' if Sinatra::Base.environment == :development
require 'sinatra/activerecord'
require_relative 'models/user'
require_relative 'models/account'
require_relative 'models/transaction'
require_relative 'models/financial_entity'
require_relative 'models/card'
require 'logger'
require 'sinatra'

class App < Sinatra::Application

  enable :sessions

  # Configuración del Logger
  set :logger, Logger.new(STDOUT)

  # Configuración de la base de datos con ActiveRecord
  set :database, { adapter: "sqlite3", database: "db/development.sqlite3" }

  configure :development do
    enable :logging
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG if development?
    set :logger, logger

    register Sinatra::Reloader
    after_reload do
      logger.info 'Reloaded!!!'
    end
  end

  # Rutas de Sinatra
  get '/' do
    logger.info "Accediendo a la página principal"
    erb :index
  end

  #Login
  get '/login' do
    erb :login
  end

  post '/login' do
    user = User.find_by(email: params[:email])
    password = params[:password]

    if user.nil?
      @error = "Usuario no encontrado"
      return erb :login
    end 

    account = user.accounts.first

    if account.nil?
      @error = "Cuenta no asociada al usuario"
      return erb :login
    end

    if user.authenticate(password)
      session[:user_dni] = user.dni
      logger.info "El usuario con DNI #{user.dni} inició sesión con la cuenta CVU: #{account.cvu} y saldo: #{account.balance}"
      redirect '/dashboard'
    else
      @error = "Email o contraseña incorrectos"
      return erb :login
    end
  end


  #Register
  get '/registro' do
    logger.info "Accediendo a la página de registro"
    erb :registro
  end

  post '/registro' do
    user = User.new(
      dni: params[:dni],
      name: params[:name],
      surname: params[:surname],
      address: params[:address],
      email: params[:email],
      password: params[:password],
      password_confirmation: params[:password_confirmation],
      date_of_birth: params[:date_of_birth]
    )

    if user.save
      account = Account.new(
        dni_owner: user.dni,
        balance: 0,
        status_active: true
        # El alias y el CVU se generan automáticamente con un callback
      )

      if account.save
        # Crear automáticamente una tarjeta Visa al crear la cuenta
        card = Card.new(
          account_cvu: account.cvu,
          responsible_name: "#{user.name} #{user.surname}",
          expire_date: Date.today.next_year(5),  # 5 años de vigencia
          service: :visa,  # Esto usa el setter especial que convertirá a integer

        )

        if card.save
          session[:user_dni] = user.dni
          
          fne_account = Account.find_by(dni_owner: "00000001")
          if fne_account
          Transaction.create!(
                source_cvu: fne_account.cvu,
                destination_cvu: account.cvu,
                amount: 500,
                details: "Bonificación por cuenta nueva",
            )
            puts "Transacción entre EntidadFinanciera y #{user.name} creada correctamente."
          else
            puts "No se pudo crear la transacción porque no existen ambas cuentas."
          end

          redirect '/dashboard'
        else
          # Si falla la creación de la tarjeta, deshacer cuenta y usuario
          account.destroy
          user.destroy
          @error = "Error al crear la tarjeta: #{card.errors.full_messages.join(', ')}"
          erb :registro
        end

      else
        user.destroy  # Deshacer creación de usuario si la cuenta falla
        @error = "Error al crear la cuenta: #{account.errors.full_messages.join(', ')}"
        erb :registro
      end
    else
      @error = "Error al crear el usuario: #{user.errors.full_messages.join(', ')}"
      erb :registro
    end
  end

  #Dashboard //Main Page
  get '/dashboard' do
    if session[:user_dni]
      user = User.find_by(dni: session[:user_dni])
      if user
        erb :dashboard, locals: { user: user }
      else
        halt 401, "Usuario no encontrado"
      end
    else
      halt 401, "No autorizado"
    end
  end

  # Cerrar sesión
  post '/logout' do
    session.clear
    redirect '/'
  end

  helpers do
    def current_user
      if session[:user_dni]
        @current_user ||= User.find_by(dni: session[:user_dni])
      end
    end
  end

  get '/profile' do
    @user = current_user 
    erb :profile
  end

  get '/cards/new' do
    erb :'newcard'
  end

  post '/cards' do
    expire_month = params[:card][:expire_date]           # formato: "2025-07"
    service = params[:card][:service].to_i               # convierte a entero
    complete_date = "#{expire_month}-01"                 # agrega día por defecto

    # Crear una nueva cuenta para la tarjeta
    card_account = Account.new(
      dni_owner: current_user.dni,
      balance: 501,
      status_active: true
      # CVU y alias generados por callback
    )

    if card_account.save
      # Crear la tarjeta asociada a esa cuenta
      card = Card.new(
        responsible_name: params[:card][:responsible_name],
        expire_date: Date.parse(complete_date),
        service: service,
        card_number: params[:card][:card_number],
        account_cvu: card_account.cvu
      )

      if card.save
        redirect '/dashboard'
      else
        card_account.destroy
        return erb :newcard, locals: { errors: card.errors.full_messages }
      end
    else
      return erb :newcard, locals: { errors: card_account.errors.full_messages }
    end
  end

  post '/cards/delete' do
    card = Card.find_by(card_number: params[:card_number])

    if card
        # Buscar la cuenta asociada y desactivarla
      # Obtener el CVU desde la tarjeta
      cvu = card.account_cvu

      # Buscar la cuenta a través del CVU y desactivarla
      account = Account.find_by(cvu: cvu)

      if account
        updated = account.update_column(:status_active, false)
        puts "¿Se actualizó el estado?: #{updated}"
      end


      card.destroy
      redirect '/dashboard'
    else
      status 404
      "Tarjeta no encontrada"
    end
  end

  get '/settings' do
    redirect '/login' unless current_user
    erb :settings, locals: { user: current_user}
  end

  post '/settings' do
    redirect '/login' unless current_user

    user = current_user

    #Verificar contraseña actual para poder modificar campos
    unless user.authenticate(params[:current_password])
      @error = "La contraseña provista es incorrecta."
      return erb :settings, locals: { user: user}
    end

    #Actualizar nombre
    user.name = params[:name] if params[:name] && !params[:name].empty?

    #Actualizar contraseña
    if params[:new_password] && !params[:new_password].empty?
      user.password = params[:new_password]
      user.password_confirmation = params[:password_confirmation]
    end

    if user.save
      @success = "Se han modificado los datos de usuario."
    else
      @error = user.errors.full_messages.join(", ")
    end

    erb :settings, locals: { user: user}
  end

  get '/confirm_delete' do
    redirect '/login' unless current_user
    erb :confirm_delete, locals: { user: current_user }
  end

  post '/delete_account' do
    redirect '/login' unless current_user

    user = current_user

    unless user.authenticate(params[:current_password])
      @error = "La contraseña es incorrecta."
      return erb :confirm_delete, locals: { user: user}
    end
    
    if user
      dni = user.dni
      user.destroy
      logger.info "Usuario con DNI #{dni} y sus cuentas han sido eliminados."
      session.clear
      redirect '/login'
    else
      @error = "Usuario no encontrado"
      erb :dashboard
    end
  end

    #Carga de saldo a tarjeta
  get '/cards/:card_number/charge_balance' do
    card = Card.find_by(card_number: params[:card_number])

    unless card
      @error = "No existe la tarjeta."
      user = current_user
      return erb :dashboard, locals: {user: user, error: @error}
    end

    account = Account.find_by(cvu: card.account_cvu)

    erb :charge_balance, locals: {card: card, account: account, error: nil}
  end

  post '/cards/:card_number/charge_balance' do
    card = Card.find_by(card_number: params[:card_number])

    unless card
      @error = "No existe la tarjeta."
      user = current_user
      return erb :dashboard, locals: {user: user, error: @error}
    end

    account = Account.find_by(cvu: card.account_cvu)
    amount = params[:amount].to_f

    if amount <= 0
      @error = "Monto invalido para la carga de saldo."
      return erb :charge_balance, locals: {card: card, account: account, error: @error}
    end

    financial_entity = User.find_by(dni: "00000001")
    financial_account = Account.find_by(dni_owner: financial_entity.dni)

    unless financial_account && financial_account.balance >= amount
      @error = "La entidad financiera no posee saldo suficiente para realizar la carga."
      return erb :charge_balance, locals: {card: card, account: account, error: @error}
    end

    account.balance += amount
    financial_account.balance -= amount

    transaction = Transaction.new(
      source_cvu: financial_account.cvu,
      destination_cvu: account.cvu,
      amount: amount,
      details: "Carga de saldo a tarjeta #{card.card_number}",
      status: "Completed"
    )
    transaction.save!
      
    @success = "Se cargaron $#{amount} correctamente a la tarjeta"
    user = current_user
    erb :dashboard, locals: {user: user, success: @success}
  end

  get '/cards/:card_number/transfer' do
    card = Card.find_by(card_number: params[:card_number])

    unless card
      @error = "No existe la tarjeta."
      user = current_user
      return erb :dashboard, locals: {user: user, error: @error}
    end
    
    account = card.account

    erb :transfer, locals: {card: card, source_account: account, dest_account: nil, error: nil}
  end

  post '/cards/:card_number/transfer' do
    source_card = Card.find_by(card_number: params[:card_number])
    dest_card = Card.find_by(account_cvu: params[:dest_card_cvu])
    amount = params[:amount].to_f

    unless source_card && dest_card
      @error = "Tarjeta de origen o destino no encontrada."
      return erb :transfer, locals: {card: source_card, source_account: source_card.account, dest_account: nil, error: @error}
    end

    if amount <= 0
      @error = "El monto debe ser mayor a 0."
      return erb :transfer, locals: {card: source_card, source_account: source_card.account, dest_account: dest_card.account, error: @error}
    end

    source_account = source_card.account
    dest_account = dest_card.account

    if source_account.balance < amount
      @error = "Saldo insuficiente para realizar la transferencia."
      return erb :transfer, locals: { card: source_card, source_account: source_account, dest_account: dest_account, error: @error}
    end

    begin
      ActiveRecord::Base.transaction do
        source_account.update!(balance: source_account.balance - amount)
        dest_account.update!(balance: dest_account.balance + amount)
      end

      @success = "Se han transferido $#{amount} a #{dest_account.cvu}. "
      user = current_user
      erb :dashboard, locals: {user: user, success: @success}

    rescue => e
      @error = "Error al realizar la transferencia: #{e.message}"
      erb :transfer, locals: {card: source_card, source_account: source_account, dest_account: dest_account, error: @error}
    end
  end
end