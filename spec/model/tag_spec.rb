require 'rails_helper'
require 'spec_helper'

describe Tag do
  before do
    @user = User.create(email: "note-thing@pm.me", password: "123456", password_confirmation: "123456",  firstname: "victor", lastname: "hugo")
    @folder = Folder.create(user:@user, title:"title1")
    @note = Note.create(title:"notetitle1", body:"body", folder:@folder)
    @goodtag = Tag.create(note: @note, title: "tag1")
  end

  it "is not valid without a title" do
    expect(Tag.new(note: @note)).to_not be_valid
  end

  it "is not valid with a title too long" do
    expect(Tag.new(note: @note, title: "aaaaa aaaaa aaaaa aaaaa aaaaa aaaaa aaaaa aaaaa")).to_not be_valid
  end

  it "is not valid with a title too short" do
    expect(Tag.new(note: @note, title: "")).to_not be_valid
  end

  it "can't have the same name" do
    expect(Tag.new(note: @note, title: "tag1")).to_not be_valid
  end



  after do
    @note.destroy
    @folder.destroy
    @user.destroy
    @goodtag.destroy
  end

end