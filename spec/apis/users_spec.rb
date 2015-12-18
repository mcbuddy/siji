require_relative '../spec_helper'

describe 'Users ' , :type => :api do

  let!(:user) { FactoryGirl.create(:user) }

  it "" do
    get "/api/v1/items/1",:formate =>:json
    last_response.status.should eql(401)
    error = {:error=>'You need to sign in or sign up before continuing.'}
    last_response.body.should  eql(error.to_json)
  end

end