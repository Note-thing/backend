require "rails_helper"

RSpec.describe "note controller", type: :request do
  before do
    @user = User.create(email: "aaa@aa.aa", password: "123456", password_confirmation: "123456", firstname: "pierre", lastname: "donini", email_validated: true)
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
    headers = { "token" => @token }
    delete "/api/v1/notes/#{@note.id}", headers: headers
    response.status.should == 200
  end

  it "should not delete a note without valid parameters" do
    headers = { "token" => @token }
    delete "/api/v1/notes/#{@note.id - 1}", headers: headers
    response.status.should == 400
  end

  it "should not delete a locked note" do
    note = Note.create(title:"notetitle2", body:"todestroy", folder:@folder, lock:true)
    headers = { "token" => @token }
    delete "/api/v1/notes/#{note.id}", headers: headers
    response.status.should == 422
  end

  it "should update a note" do
    hash = {title: "title1", body:"body--modified", folder_id:@folder.id}
    headers = { "token" => @token, "CONTENT_TYPE" => "application/json" }
    put "/api/v1/notes/#{@note.id}", params: hash.to_json, headers: headers
    response.status.should == 200
    assert Note.find(@note.id).body == "body--modified"
  end

  it "should note update a locked note" do
    @note.lock = true
    @note.save
    hash = {title: "title1", body:"body--modified2", folder_id:@folder.id}
    headers = { "token" => @token, "CONTENT_TYPE" => "application/json" }
    put "/api/v1/notes/#{@note.id}", params: hash.to_json, headers: headers
    response.status.should == 422
    assert Note.find(@note.id).body != "body--modified2"
    @note.lock = false
    @note.save
  end

  it "should note update a read-only note" do
    @note.read_only = true
    @note.save
    hash = {title: "title1", body:"body--modified2", folder_id:@folder.id}
    headers = { "token" => @token, "CONTENT_TYPE" => "application/json" }
    put "/api/v1/notes/#{@note.id}", params: hash.to_json, headers: headers
    response.status.should == 422
    assert Note.find(@note.id).body != "body--modified2"
    @note.read_only = false
    @note.save
  end

  it "should unlock the note" do
    @note.lock = true
    @note.save
    headers = { "token" => @token }
    get "/api/v1/notes/unlock/#{@note.id}", headers: headers
    response.status.should == 204
    assert Note.find(@note.id).lock == false
    @note.lock = false
    @note.save
  end
  it "should display the structure" do
    get '/api/v1/structure', headers: @token_headers
    structure = JSON.parse(response.body)
    response.status.should == 200
  end







end