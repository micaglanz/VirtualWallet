# Modelo de ActiveRecord (ejemplo con una tabla `users`)
# models/user.rb
class User < ActiveRecord::Base

    #Authentication
    has_secure_password

    self.primary_key = 'dni'

    #Relationships
    has_many :accounts, foreign_key: :dni_owner, primary_key: :dni, inverse_of: :user, dependent: :destroy


    #Validations
    validates :dni, presence: true, uniqueness: true
    validates :name, :surname, :address, :date_of_birth, presence: true
    validates :email, presence: true
      # Validar que password y password_confirmation coincidan (opcional, pero recomendado)
    validate :password_confirmation_matches

    def password_confirmation_matches
        if password != password_confirmation
        errors.add(:password_confirmation, "no coincide con la contraseña")
        end
    end

end