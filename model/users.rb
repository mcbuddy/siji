require 'bcrypt'

class Users
  include Mongoid::Document
  include Mongoid::Timestamps
  include BCrypt

  attr_accessor :password, :password_confirmation
  attr_protected :password_hash

  field :username, type: String
  field :email, type: String
  field :first_name, type: String
  field :last_name, type: String
  field :password_hash, type: String

  validates_presence_of :email, message: 'Email is required.'

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def self.authentication(data)
    user = self.find_by(email: data['email'])
    if user.password == data['password']
      # return 201
      token = generate_access_token
      return token
      true
    else
      # return 404
      false
    end
  end

  def self.generate_access_token
    auth_token   = SecureRandom.hex
    expired_time = Time.now + 3600 # token will expired within a hour
    access_token = { auth_token: auth_token, expired_ob: expired_time }
    return access_token
  end


end

