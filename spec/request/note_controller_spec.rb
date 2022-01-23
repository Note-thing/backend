require "rails_helper"

RSpec.describe "note controller", type: :request do
  before do
    @user = User.create(email: "aaa@aa.aa", password: "123456", password_confirmation: "123456", firstname: "pierre", lastname: "donini")
    @folder = Folder.new(user: @user, title: "test folder")
    @note = Note.create(title:"notetitle1", body:"body", folder:@folder)
    valid_credentials = { email: "aaa@aa.aa",  password: "123456"}
    post '/api/v1/signin', params: valid_credentials
    @token = JSON.parse(response.body)["token"]
    @token_headers = { "token" => @token}
  end

  it "should retrieve a note when logged in" do
    get "/api/v1/notes/#{@note.id}", params: nil, headers: @token_headers
    puts "reposne", response.body
    response.status.should == 200
  end

  it "should throw an error if i'm not logged in" do
    get "/api/v1/notes/#{@note.id}", params: nil, headers: nil
    response.status.should == 403
  end

  it "should throw an error if the note doesn't exists" do
    get "/api/v1/notes/100", params: nil, headers: @token_headers
    response.status.should == 400
  end

  it "should create a note given valid parameters" do
    hash = {title: "title1", body:"body1", folder_id:@folder.id}
    headers = { "token" => @token, "CONTENT_TYPE" => "application/json" }
    post "/api/v1/notes", params: hash.to_json, headers: headers
    response.status.should == 200
  end

  it "should not create a note without valid parameters" do
    hash = {body:"body1", folder_id:@folder.id}
    headers = { "token" => @token, "CONTENT_TYPE" => "application/json" }
    post "/api/v1/notes", params: hash.to_json, headers: headers
    response.status.should == 400

    hash = {title: "title1", folder_id:@folder.id}
    headers = { "token" => @token, "CONTENT_TYPE" => "application/json" }
    post "/api/v1/notes", params: hash.to_json, headers: headers
    response.status.should == 200

    hash = {title: "title1", body:"body1"}
    headers = { "token" => @token, "CONTENT_TYPE" => "application/json" }
    post "/api/v1/notes", params: hash.to_json, headers: headers
    response.status.should == 400
  end

  it "should delete a note with valid parameters" do

  end




end