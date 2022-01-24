require "rails_helper"

RSpec.describe "folders controller", type: :request do
  before do
    @user = User.create(email: "aaa@aa.aa", password: "123456", password_confirmation: "123456", firstname: "pierre", lastname: "donini")
    @folder = Folder.create(user: @user, title: "test folder")
    @note = Note.create(title:"notetitle1", body:"body", folder:@folder)
    valid_credentials = { email: "aaa@aa.aa",  password: "123456"}
    post '/api/v1/signin', params: valid_credentials
    @token = JSON.parse(response.body)["token"]
    @token_headers = { "token" => @token}
    @modify_headers = { "token" => @token, "CONTENT_TYPE" => "application/json"}
  end

  it "should return all our folders" do
    get '/api/v1/folders', headers: @token_headers
    response.status.should == 200
    puts response.body
    folders = JSON.parse(response.body)
    assert folders[0]["id"] == @folder.id
  end

  it "should create a new folder" do
    hash = { title: "newtitle"}
    token_headers = { "token" => @token, "CONTENT_TYPE" => "application/json"}
    post '/api/v1/folders', params: hash.to_json, headers: token_headers
    response.status.should == 201
    puts response.body
    folder = JSON.parse(response.body)
    puts "Folder id", folder["id"]
    assert Folder.find(folder["id"]) != nil
  end

  it "should not work without a login" do
    hash = { title: "newtitle"}
    headers = { "CONTENT_TYPE" => "application/json"}
    post '/api/v1/folders', params: hash.to_json, headers: headers
    response.status.should == 403
    put "/api/v1/folders/#{@folder.id}", params: hash.to_json, headers: headers
    response.status.should == 403
    delete "/api/v1/folders/#{@folder.id}", headers: headers
    response.status.should == 403
  end

  it "should delete a folder" do
    delete "/api/v1/folders/#{@folder.id}", headers: @token_headers
    assert Folder.find { @folder.id } == nil
  end

  it "should not delete a foreign folder" do
    user = User.create(email: "bbb@bb.bb", password: "123456", password_confirmation: "123456", firstname: "pierre", lastname: "donini")
    folder = Folder.create(user: user, title: "title2")
    delete "/api/v1/folders/#{folder.id}", headers: @token_headers
    response.status.should == 400
    assert Folder.find(folder.id) != nil
  end

  it "should modify a folder" do
    hash = {title: "newtitle"}
    put "/api/v1/folders/#{@folder.id}", headers: @modify_headers, params: hash.to_json
    response.status.should == 200
    assert Folder.find(@folder.id).title == "newtitle"
  end

  it "should not modifiy a foreign folder" do
    user = User.create(email: "bbb@bb.bb", password: "123456", password_confirmation: "123456", firstname: "pierre", lastname: "donini")
    folder = Folder.create(user: user, title: "title2")
    hash = {title: "newtitle"}
    put "/api/v1/folders/#{folder.id}", params: hash.to_json, headers: @modify_headers
    response.status.should == 400
    assert Folder.find(folder.id).title != "newtitle"
  end
end
