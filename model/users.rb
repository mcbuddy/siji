require 'bcrypt'

class Users
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::MassAssignmentSecurity

  attr_accessible :password
  attr_protected :password_hash

  field :username, type: String
  field :email, type: String
  field :first_name, type: String
  field :last_name, type: String
  field :password_hash, type: String
  field :auth_token, type: String
  field :expired_time, type:Date

  validates_presence_of :email, message: 'Email is required.'

  # before_save :secure_password

  def password
    @password ||= BCrypt::Password.new(password_hash)
  end

  def password=(new_password)
    @password = BCrypt::Password.create(new_password)
    self.password_hash = @password
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
                                      :domain         => siji_inbox['domain']
                    }}

    Pony.email( :to => user.email,
                :subject => subject,
                :body => body )

  end

  def self.reset_password(data)
    user = self.find_by(email: data['email'])
    random_pwd = SecureRandom.hex(7)
    user.password = random_pwd
    user.save
  #   send email action here
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
    access_token = { auth_token: auth_token, expired_at: expired_time }
    return access_token
  end

  def self.check_token(token)
    if self.auth_token == token
      check_expired_token
      response = {success: true, code: 200}
      response.to_json
    else
      response = {success: false, code: 403 }
      response.to_json
    end
  end

  def self.check_expired_token
    current_time = Time.now
    return true unless self.expired_at < current_time
    end
end