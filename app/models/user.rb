# Modelo de ActiveRecord (ejemplo con una tabla `users`)
# models/user.rb
class User < ActiveRecord::Base
    #Relationships
    has_one :account, foreign_key: :dni_owner, primary_key: :dni

    #Validations
    validates :dni, presence: true, uniquness: true
    validates :registration_code, presence: true, uniquness: true
    validates :name, :surname, :address, :mail, :date_of_birth
    validates :mail, format: { with: URI::MailTo::EMAIL_REGEXP }
end