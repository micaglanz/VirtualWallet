# Modelo de ActiveRecord (ejemplo con una tabla `users`)
# models/user.rb
class User < ActiveRecord::Base

    self.primary_key = 'dni'

    #Relationships
    has_many :accounts, foreign_key: :dni_owner, primary_key: :dni, inverse_of: :user


    #Validations
    validates :dni, presence: true, uniqueness: true
    validates :name, :surname, :address, :date_of_birth, presence: true
    validates :email, presence: true
end