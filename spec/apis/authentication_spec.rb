require_relative '../spec_helper'

describe 'Users API' do
  before(:all) do
    @param = {:data => {email: "test#{Time.now.to_i}@test.com", password: 'Test1234'}}.to_json
  end
  # let!(:user) { FactoryGirl.create(:user) }

  it 'Signup new user' do
    post '/api/signup', @param,:formate =>:json
    puts last_response
    expect(last_response.status).to eql(201)
    # error = {:error=>'You need to sign in or sign up before continuing.'}
    # last_response.body.should  eql(error.to_json)
  end

end