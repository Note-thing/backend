require "rails_helper"

RSpec.describe "tags controller", type: :request do
  before do
    @user = User.create(email: "aaa@aa.aa", password: "123456", password_confirmation: "123456", firstname: "pierre", lastname: "donini")
    @folder = Folder.create(user: @user, title: "test folder")
    valid_credentials = { email: "aaa@aa.aa",  password: "123456"}
    @note = Note.create(title:"notetitle1", body:"body", folder:@folder)
    @tag = Tag.create(title: "title", note: @note)

    post '/api/v1/signin', params: valid_credentials
    @token = JSON.parse(response.body)["token"]
    @token_headers = { "token" => @token}
    @modify_headers = { "token" => @token, "CONTENT_TYPE" => "application/json"}
  end

  it 'should show a tag' do
    get "/api/v1/tags/#{@tag.id}", headers: @token_headers
    response.status.should == 200
    tags = JSON.parse(response.body)
    assert tags["id"] == @tag.id
  end

  it 'should add a tag' do
    hash = { title: "TAG2", note_id: @note.id}
    post"/api/v1/tags", headers: @modify_headers, params: hash.to_json
    response.status.should == 201
    newtag = JSON.parse(response.body)
    puts newtag
    assert Note.find(@note.id).tags.find(newtag["id"])
  end

  it 'should delete a tag' do
    delete "/api/v1/tags/#{@tag.id}", headers: @token_headers
    response.status.should == 200
    expect(Note.find(@note.id).tags).to be_empty
  end

  it 'should update a tag' do
    hash = { title: "TAG2", note_id: @note.id}
    put"/api/v1/tags/#{@tag.id}", headers: @modify_headers, params: hash.to_json
    response.status.should == 200
    newtag = JSON.parse(response.body)
    puts newtag
    assert Note.find(@note.id).tags.find(newtag["id"])
  end

  it 'should not work without login' do
    bad_headers = { 'CONTENT_TYPE' => 'application/json' }
    hash = { title: "TAG2", note_id: @note.id}
    get "/api/v1/tags/#{@tag.id}"
    response.status.should == 403
    post"/api/v1/tags", headers: bad_headers, params: hash.to_json
    response.status.should == 403
    delete "/api/v1/tags/#{@tag.id}"
    response.status.should == 403
    put"/api/v1/tags/#{@tag.id}", headers: bad_headers, params: hash.to_json
    response.status.should == 403

    expect(Note.find(@note.id).tags).to contain_exactly(@tag)
  end

  it 'should not work with incorrect parameters' do
    hash = { note_id: @note.id}
    get "/api/v1/tags/#{@tag.id + 1}", headers: @token_headers
    assert_response :missing
    post"/api/v1/tags", headers: @modify_headers, params: hash.to_json
    response.status.should == 400
    delete "/api/v1/tags/#{@tag.id + 1}", headers: @modify_headers
    assert_response :missing
    hash = { title: "newtitle" }
    put"/api/v1/tags/#{@tag.id}", headers: @modify_headers, params: hash.to_json
    response.status.should == 404
  end

  it 'should not add the same tag' do
    hash = { title: "title", note_id: @note.id}
    post"/api/v1/tags", headers: @modify_headers, params: hash.to_json
    response.status.should == 400
    expect(Note.find(@note.id).tags).to contain_exactly(@tag)
  end

  it 'should not work with a foreign note' do
    user = User.create(email: "bbb@bb.bb", password: "123456", password_confirmation: "123456", firstname: "pierre", lastname: "donini")
    folder = Folder.create(user: user, title: "test folder")
    note = Note.create(title:"notetitle1", body:"body", folder:folder)
    tag = Tag.create(title: "title", note: note)
    hash = { title: "TAG2", note_id: note.id}

    get "/api/v1/tags/#{tag.id}", headers: @token_headers
    response.status.should == 400
    expect(Note.find(note.id).tags).to contain_exactly(tag)
    post"/api/v1/tags", headers: @modify_headers, params: hash.to_json
    response.status.should == 400
    expect(Note.find(note.id).tags).to contain_exactly(tag)
    delete "/api/v1/tags/#{tag.id}", headers: @token_headers
    response.status.should == 400
    expect(Note.find(note.id).tags).to contain_exactly(tag)
    hash = { title: "TAG2", note_id: note.id}
    put"/api/v1/tags/#{tag.id}", headers: @modify_headers, params: hash.to_json
    response.status.should == 400
    expect(Note.find(note.id).tags).to contain_exactly(tag)
  end


end
