require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/reloader' if Sinatra::Base.environment == :development
require 'sinatra/activerecord'
require_relative 'models/user'
require 'logger'
require 'sinatra'




class User < ActiveRecord::Base
end

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name

      t.timestamps
    end
  end
end

class App < Sinatra::Application

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

end

# Rutas de Sinatra
get '/' do
  logger.info "Accediendo a la página principal"
  erb :index
end

get '/registro' do
  logger.info "Accediendo a la página de registro"
  erb :registro
end
# Ruta para agregar un usuario
#post '/add_user' do
#  user = User.create(name: params[:name])
#  logger.info "Nuevo usuario creado: #{user.name}"
#  "Usuario #{user.name} creado con éexito!"
#end

