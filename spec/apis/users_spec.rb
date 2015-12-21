require_relative '../spec_helper'

describe 'Registration and login API test' do
  before(:all) do
    @param = {email: "test#{Time.now.to_i}@test.com", password: 'Test1234'}.to_json
  end

  it 'Signup new user' do
    post '/api/signup', @param,:formate =>:json
    body = JSON.parse last_response.body
    expect(body['message']).to eql('Email Registration has been sent.')
    expect(last_response.status).to eql(200)
  end

  it 'Login using that user' do
    post '/api/login', @param,:formate =>:json
    body = JSON.parse last_response.body
    expect(body['auth_token']).not_to be_nil
    expect(body['expired_time']).not_to be_nil
    expect(last_response.status).to eql(200)
    $token = {auth_token: body['auth_token']}.to_json
  end

  it 'Query all users' do
    get '/api/users', headers:$token, :formate =>:json
    body = JSON.parse last_response.body
    puts body
    # expect(body['message']).to eql('Email Registration has been sent.')
    # expect(last_response.status).to eql(200)
  end


end