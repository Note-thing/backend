require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  test "should not save a note without title and body" do
    note = Note.new
    assert_not note.validate, "Saved the note without a title and a body"
  end

  test "should save a note with a title and a body" do
    note = Note.new({:title => "My title", :body => "My body"})
    assert note.validate, "Didn't save the note with a title and a body"
  end

  test "should not save a note with a title bigger then 64 characters" do
    note = Note.new({:title => "0" * 65, :body => "My body"})
    assert_not note.validate, "Saved the note with a title bigger then 64 characters"
  end

  test "should not save a note with a title smaller then 1 character" do
    note = Note.new({:title => "", :body => "My body"})
    assert_not note.validate, "Saved the note with a title smaller then 1 character"
  end

  test "should not save a note with a body bigger then 1024 characters" do
    note = Note.new({:title => "My title", :body => "0" * 1025})
    assert_not note.validate, "Saved the note with a body bigger then 1024 characters"
  end
end