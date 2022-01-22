require 'rails_helper'
require 'spec_helper'

describe User do
  it "should not work without necessary fields" do
    expect(User.new(email: "aaa@aaa.aa", password: "password", password_confirmation: "password", firstname: "firstname", lastname: "lastname")).to be_valid
    expect(User.new(password: "password", password_confirmation: "password", firstname: "firstname", lastname: "lastname")).to be_invalid
    expect(User.new(email: "aaa@aaa.aa", password_confirmation: "password", firstname: "firstname", lastname: "lastname")).to be_invalid
    expect(User.new(email: "aaa@aaa.aa", password: "password", firstname: "firstname", lastname: "lastname")).to be_invalid
    expect(User.new(email: "aaa@aaa.aa", password: "password", password_confirmation: "password", lastname: "lastname")).to be_invalid
    expect(User.new(email: "aaa@aaa.aa", password: "password", password_confirmation: "password", firstname: "firstname")).to be_invalid
  end

  it "should not work with incorrect email" do
    expect(User.new(email: "aaa", password: "password", password_confirmation: "password", firstname: "firstname", lastname: "lastname")).to be_invalid
  end

  it "should not work with incorrect password length" do
    expect(User.new(email: "aaa@aaa.aa", password: "pass", password_confirmation: "pass", firstname: "firstname", lastname: "lastname")).to be_invalid
  end

  it "should not work with incorrect firstname / lastname" do
    expect(User.new(email: "aaa@aaa.aa", password: "password", password_confirmation: "password", firstname: "firstname1", lastname: "@lastname")).to be_invalid
  end

end