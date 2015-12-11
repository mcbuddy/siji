
class Users
  include Mongoid::Document

  field :user_id, type: Integer
  field :name, type: String
  field :email, type: String
end