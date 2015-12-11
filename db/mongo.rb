require 'mongo'
require 'bson'

Module MongoDB
  def self.client
    client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'siji')
  end


end
