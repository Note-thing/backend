require "rails_helper"

RSpec.describe "passwords controller", type: :request do
  before do
    @user = User.create(email: "aaa@aaa.aa", password: "123456", password_confirmation: "123456", firstname: "pierre", lastname: "donini", email_validated: true)
  end

  it 'should modify the password given a valid token' do
    headers = { 'CONTENT_TYPE' => 'application/json' }
    hash = { 'email' => 'aaa@aaa.aa'}
    post '/api/v1/password/forgot', headers: headers, params: hash.to_json
    response.status.should == 200

    user = User.find(@user.id)
    user.reset_password_sent_at = Time.now.utc
    hash = { 'password' => '12345678', 'password_token' => user.reset_password_token }
    post '/api/v1/password/reset', headers: headers, params: hash.to_json
    response.status.should == 200
    assert user.password_digest != User.find(@user.id).password_digest
  end
end