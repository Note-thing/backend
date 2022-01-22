require 'rails_helper'
require 'spec_helper'

describe Note do

  before do
    @user = User.create(email: "note-thing@pm.me", password: "123456", password_confirmation: "123456", firstname: "victor", lastname: "hugo")
    @folder = Folder.new(user: @user, title: "test folder")
    @note_title = "note title"
  end

  it "is not valid without a title" do
    expect(Note.new(folder: @folder)).to_not be_valid
  end

  it "is not valid without a folder" do
    expect(Note.new(title: @note_title)).to_not be_valid
  end

  it "is not valid with a title too short" do
    expect(Note.new(folder: @folder, title: "")).not_to be_valid
  end

  it "is not valid with a title too short" do
    expect(Note.new(folder: @folder, title: "1" * 65)).not_to be_valid
  end

  it "can be deleted" do
    note = Note.create(folder: @folder, title: @note_title)
    expect(note.delete).to be_valid
  end

  after do
    @folder.destroy
    @user.destroy
  end

end