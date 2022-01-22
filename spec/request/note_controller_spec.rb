require "rails_helper"

RSpec.describe "note controller", type: :request do
  before do
    @user = User.create(email: "aaa@aa.aa", password: "123456", password_confirmation: "123456", firstname: "pierre", lastname: "donini")
    @folder = Folder.new(user: @user, title: "test folder")
    @note = Note.create(title:"notetitle1", body:"body", folder:@folder)
    valid_credentials = { email: "aaa@aa.aa",  password: "123456"}
    post '/api/v1/signin', params: valid_credentials
    @token = JSON.parse(response.body)["token"]
  end

  it "should retrieve a note when logged in" do
    headers = { "token" => @token }
    get "/api/v1/notes/#{@note.id}", params: nil, headers: headers
    puts "reposne", response.body
    response.status.should == 200
  end



end