require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/reloader' if Sinatra::Base.environment == :development
require 'sinatra/activerecord'
require_relative 'models/user'
require_relative 'models/account'
require_relative 'models/transaction'
require_relative 'models/financial_entity'
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
  
    dni = params[:dni]
    password = params[:password]
  
    user = User.find_by(email: params[:email])

  # user = User.find_by(dni: dni)

    if user.nil?
      @error = "Usuario no encontrado"
      return erb :login
    end

  
  account = user.account

  if account.nil?
    @error = "Cuenta no asociada al usuario"
    return erb :login
  end

  #  if user && user.authenticate(params[:password])
  
    if account.authenticate(password)
      session[:user_dni] = user.dni
      logger.info "El usuario con DNI #{user.dni} inició sesión con la cuenta CVU: #{account.cvu} y saldo: #{account.balance}"
      redirect '/dashboard'
    else
      @error = "Email o contraseña incorrectos"
      erb :login
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
      date_of_birth: params[:date_of_birth]
    )

    if user.save
      account = Account.new(
        dni_owner: user.dni,
        password: params[:password],
        password_confirmation: params[:password_confirmation],
        balance: 500,
        status_active: true
        # el alias y el cvu se generan automáticamente con un callback
      )

      puts account.password_digest

      if account.save
        session[:user_dni] = user.dni
        redirect '/dashboard'
      else
        user.destroy  # deshacer creación de usuario si la cuenta falla
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
end