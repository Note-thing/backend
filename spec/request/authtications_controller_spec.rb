require "rails_helper"

RSpec.describe "folders controller", type: :request do
  before do
    @user = User.create(email: "aaa@aa.aa", password: "123456", password_confirmation: "123456", firstname: "pierre", lastname: "donini", email_validated: true)
  end


  #it 'should register a user' do
  #  header = {'CONTENT_TYPE' => 'application/json'}
  # hash = { email: "bbb@bb.bb", password: '123456', password_confirmation: '123456', firstname: 'noah', lastname: 'fusi' }
  # post '/api/v1/signup', params: hash.to_json, headers: header
  # puts response.body
  # response.status.should == 201
  #end
  it 'should work with correct credentials' do
    valid_credentials = { email: "aaa@aa.aa",  password: "123456"}
    post '/api/v1/signin', params: valid_credentials
    response.status.should == 200
  end

  it 'should not work with correct credentials' do
    valid_credentials = { email: "bbb@aa.aa",  password: "123456"}
    post '/api/v1/signin', params: valid_credentials
    response.status.should == 403
  end
end
