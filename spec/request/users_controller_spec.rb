require "rails_helper"

RSpec.describe "users controller", type: :request do
  before do
    @user = User.create(email: "aaa@aa.aa", password: "123456", password_confirmation: "123456", firstname: "pierre", lastname: "donini", email_validated: true)
    valid_credentials = { email: "aaa@aa.aa",  password: "123456"}
    post '/api/v1/signin', params: valid_credentials
    @token = JSON.parse(response.body)["token"]
    @token_headers = { "token" => @token, 'CONTENT_TYPE' => 'application/json' }
  end
  it "should change user data" do
    hash = { email: 'bbb@bbb.bb', firstname: 'paul', lastname: 'gauthier' }
    patch '/api/v1/users', headers: @token_headers, params: hash.to_json
    puts response.body
    response.status.should == 200
  end

end