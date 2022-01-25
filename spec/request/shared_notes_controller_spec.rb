require "rails_helper"

RSpec.describe "shared note controller", type: :request do
  before do
    @user = User.create(email: "aaa@aa.aa", password: "123456", password_confirmation: "123456", firstname: "pierre", lastname: "donini", email_validated: true)
    @folder = Folder.new(user: @user, title: "test folder")
    @note = Note.create(title:"notetitle1", body:"body", folder:@folder)
    valid_credentials = { email: "aaa@aa.aa",  password: "123456"}
    post '/api/v1/signin', params: valid_credentials
    @token = JSON.parse(response.body)["token"]
    @token_headers = { "token" => @token }
    @modify_headers = { 'token' => @token, 'CONTENT_TYPE' => 'application/json'}
  end

  it 'should create a shared note' do
    hash = {'note_id' => @note.id, 'sharing_type' => 'read_only'}
    post '/api/v1/shared_notes', headers: @modify_headers, params: hash.to_json
    response.status.should == 201
    hash = {'note_id' => @note.id, 'sharing_type' => 'mirror'}
    post '/api/v1/shared_notes', headers: @modify_headers, params: hash.to_json
    response.status.should == 201
    hash = {'note_id' => @note.id, 'sharing_type' => 'copy_content'}
    post '/api/v1/shared_notes', headers: @modify_headers, params: hash.to_json
    response.status.should == 201
  end

  it 'should display a shared note' do
    hash = {'note_id' => @note.id, 'sharing_type' => 'copy_content'}
    post '/api/v1/shared_notes', headers: @modify_headers, params: hash.to_json
    response.status.should == 201
    shared_note = JSON.parse(response.body)
    assert SharedNote.find(shared_note['id'])
    get "/api/v1/shared_notes/#{shared_note['id']}", headers: @token_headers
    response.status.should == 200
  end

  it 'should delete a shared note' do
    hash = {'note_id' => @note.id, 'sharing_type' => 'copy_content'}
    post '/api/v1/shared_notes', headers: @modify_headers, params: hash.to_json
    response.status.should == 201
    shared_note = JSON.parse(response.body)
    assert SharedNote.find(shared_note['id'])
    delete "/api/v1/shared_notes/#{shared_note['id']}", headers: @token_headers
    response.status.should == 200
  end

  it 'should copy a shared note (copy content)' do
    user = User.create(email: "bbb@bb.bb", password: "123456", password_confirmation: "123456", firstname: "pierre", lastname: "donini", email_validated: true)
    folder = Folder.new(user: user, title: "other folder")
    note = Note.create(title:"notetitle1", body:"body", folder:folder)
    uuid = SecureRandom.uuid
    shared_note = SharedNote.create(title: note.title, body: note.body, note_id: note.id, sharing_type: 'copy_content', uuid: uuid)

    hash = {folder_id: @folder.id}
    post "/api/v1/shared_notes/#{uuid}/copy", params: hash.to_json, headers: @modify_headers
    response.status.should == 200
    new_note = JSON.parse(response.body)
    assert Folder.find(@folder.id).notes.find(new_note['id'])

    note.body = 'new body'
    note.save

    get "/api/v1/notes/#{new_note['id']}", headers: @token_headers
    response.status.should == 200
    puts "CHILDREN NOTE", response.body
    new_note = JSON.parse(response.body)
    assert new_note['body'] != 'new body'
  end

  it 'should copy a shared note (mirror)' do
    user = User.create(email: "bbb@bb.bb", password: "123456", password_confirmation: "123456", firstname: "pierre", lastname: "donini", email_validated: true)
    folder = Folder.new(user: user, title: "other folder")
    note = Note.create(title:"notetitle1", body:"body", folder:folder)
    uuid = SecureRandom.uuid
    valid_credentials =  { email:'bbb@bb.bb', password: '123456'}
    post '/api/v1/signin', params: valid_credentials
    token = JSON.parse(response.body)["token"]
    token_headers = { "token" => @token }
    modify_headers = { 'token' => token, 'CONTENT_TYPE' => 'application/json' }

    shared_note = SharedNote.create(title: note.title, body: note.body, note_id: note.id, sharing_type: 'mirror', uuid: uuid)

    hash = {folder_id: @folder.id}
    post "/api/v1/shared_notes/#{uuid}/copy", params: hash.to_json, headers: @modify_headers
    response.status.should == 200
    new_note = JSON.parse(response.body)
    assert Folder.find(@folder.id).notes.find(new_note['id'])
    assert Note.find(new_note['id']).reference_note != nil
    assert Note.find(new_note['id']).read_only == false

    hash = {title: "title1", body:"body--modified", folder_id:folder.id}
    put "/api/v1/notes/#{note.id}", params: hash.to_json, headers: modify_headers
    response.status.should == 200

    get "/api/v1/notes/#{new_note['id']}", headers: @token_headers
    response.status.should == 200
    puts "MIRROR NOTE", response.body
    new_note = JSON.parse(response.body)
    assert new_note['body'] == 'body--modified'
    puts "PARENT NOTE", Note.find(note.id).lock
    assert Note.find(note.id).lock == true
    assert Note.find(note.id).has_mirror == true
  end

  it 'should copy a shared note (read_only)' do
    user = User.create(email: "bbb@bb.bb", password: "123456", password_confirmation: "123456", firstname: "pierre", lastname: "donini", email_validated: true)
    folder = Folder.new(user: user, title: "other folder")
    note = Note.create(title:"notetitle1", body:"body", folder:folder)
    uuid = SecureRandom.uuid

    valid_credentials =  { email:'bbb@bb.bb', password: '123456'}
    post '/api/v1/signin', params: valid_credentials
    token = JSON.parse(response.body)["token"]
    token_headers = { "token" => @token }
    modify_headers = { 'token' => token, 'CONTENT_TYPE' => 'application/json' }

    shared_note = SharedNote.create(title: note.title, body: note.body, note_id: note.id, sharing_type: 'read_only', uuid: uuid)

    hash = {folder_id: @folder.id}
    post "/api/v1/shared_notes/#{uuid}/copy", params: hash.to_json, headers: @modify_headers
    response.status.should == 200
    new_note = JSON.parse(response.body)
    assert Folder.find(@folder.id).notes.find(new_note['id'])
    assert Note.find(new_note['id']).reference_note != nil
    assert Note.find(new_note['id']).read_only == true

    hash = {title: "title1", body:"body--modified", folder_id:folder.id}
    put "/api/v1/notes/#{note.id}", params: hash.to_json, headers: modify_headers
    response.status.should == 200

    get "/api/v1/notes/#{new_note['id']}", headers: @token_headers
    response.status.should == 200
    puts "CHILDREN NOTE", response.body
    new_note = JSON.parse(response.body)
    assert new_note['body'] == 'body--modified'

    puts "PARENT NOTE", Note.find(note.id).lock
    assert Note.find(note.id).lock == nil
    assert Note.find(note.id).has_mirror == false
  end

end