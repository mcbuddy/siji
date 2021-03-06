require 'bcrypt'
require 'autoinc'

class Users
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Autoinc
  include ActiveModel::MassAssignmentSecurity

  attr_accessible :password, :auth_token, :expired_time, :role_id
  attr_protected :password_hash

  field :id, type: Integer
  increments :id

  field :username, type: String
  field :email, type: String
  field :first_name, type: String
  field :last_name, type: String
  field :password_hash, type: String
  field :auth_token, type: String
  field :expired_time, type:Date
  field :role_id

  validates :email, :uniqueness => true, :presence => true #, message: 'Email is required.'

  embeds_one :roles #, default: 'Standard'

  def password
    @password ||= BCrypt::Password.new(password_hash)
  end

  def password=(new_password)
    @password = BCrypt::Password.create(new_password)
    self.password_hash = @password
  end

  def self.assign_role(user)
    user.role_id = Roles.first.id
  end

  def self.send_email(user, subject, body)
    # getting the mailtrap info and send it to pony mailer
    response = RestClient.get "https://mailtrap.io/api/v1/inboxes.json?api_token=#{ENV['MAILTRAP_API_TOKEN']}"
    siji_inbox = JSON.parse(response)[0]

    Pony.options = {:via => :smtp,
                    :via_options => { :address        => siji_inbox['domain'],
                                      :port           => siji_inbox['smtp_ports'][0],
                                      :user_name      => siji_inbox['username'],
                                      :password       => siji_inbox['password'],
                                      :authentication => :plain,
                                      :domain         => siji_inbox['domain'] }}

    Pony.mail({:to => user.email,
                :subject => subject,
                :body => body })
  end

  def self.send_email_registration(user)
    subject_email = 'Welcome to Siji'
    body_email    = "Hi #{user.first_name},\nYou have been register as user at Siji\nThank you! "

    self.send_email(user, subject_email, body_email)
    resposse = {message: 'Email Registration has been sent.'}
    return resposse
  end


  def self.reset_password(email)
    user = self.find_by(email: email)
    random_pwd = SecureRandom.hex(7)
    user.password = random_pwd
    user.save

    subject_email = 'Your Password has been reset'
    body_email    = "Hi #{user.first_name},\nWe recently received a request to reset your password\nYour new password is: #{random_pwd}\nThank you ! "

    self.send_email(user, subject_email, body_email)
    resposse = {message: 'Your new password has been sent to your email address.'}
    return resposse
  end

  def self.authentication(data)
    user = self.find_by(email: data['email'])
    if user.password == data['password']
      token = generate_access_token
      user.auth_token = token[:auth_token]
      user.expired_time = token[:expired_time]
      user.save
      return token
    else
      response = {success: false, code: 403 }
      return response
    end
  end

  def self.generate_access_token
    auth_token   = SecureRandom.hex
    expired_time = Time.now + 3600 # token will expired within a hour
    access_token = { auth_token: auth_token, expired_time: expired_time}
    return access_token
  end

  def self.check_token(token)
    user = Users.find_by(auth_token: token)
      if user.auth_token == token
        response = check_expired_token(user)
      else
        response = {success: false, code: 403 }
      end
    return response
  end

  def self.check_expired_token(user)
    current_time = Time.now
    if current_time > user.expired_time
      response = {success: false, message:'Your token expired, please re-login to get new token' }
    else
      response = {success: true}
    end
    return response
  end
end