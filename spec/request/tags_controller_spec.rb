require "rails_helper"

RSpec.describe "note controller", type: :request do
  before do
    @user = User.create(email: "aaa@aa.aa", password: "123456", password_confirmation: "123456", firstname: "pierre", lastname: "donini")
    @folder = Folder.create(user: @user, title: "test folder")
    @note = Note.create(title:"notetitle1", body:"body", folder:@folder)
    @tag = Tag.create(title: "title", note: @note)
  end
  it 'should do something' do

  end
end
