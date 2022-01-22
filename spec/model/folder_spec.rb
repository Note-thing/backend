require 'rails_helper'
require 'spec_helper'

describe Folder do

  before do
    @user = User.create(email: "note-thing@pm.me", password: "123456", password_confirmation: "123456", firstname: "victor", lastname: "hugo")
  end
  it "is not valid without a title" do
    expect(Folder.new(user:@user)).to_not be_valid
  end

  it "is not valid with a title which is too long" do
    expect(Folder.new(user:@user, title: "aaaaa aaaaa aaaaa aaaaa")).to_not be_valid
  end

  it "is not valid with a title which is too short" do
    expect(Folder.new(user:@user, title: "")).to_not be_valid
  end

  it "is not valid without a user" do
    expect(Folder.new(user: nil, title: "ok title")).to_not be_valid
  end

  it "can be deleted" do
    folder = Folder.create(user:@user, "title": "folder")
    expect(folder.delete).to be_valid
  end

  after do
    @user.destroy
  end
end