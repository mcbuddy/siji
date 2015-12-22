require 'autoinc'

class Roles
  include Mongoid::Document
  include Mongoid::Autoinc

  field :id, type: String
  increments :id

  field :name, type: String

  embedded_in :user

end