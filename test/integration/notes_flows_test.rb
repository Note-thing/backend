require 'test_helper'

class NotesFlowsTest < ActionDispatch::IntegrationTest
  setup do
    clear_db
  end

  test "should get index" do
    get api_v1_notes_url, as: :json
    assert_response :success, "an error occurred when getting the notes"
    assert_equal 0, @response.parsed_body.length, "the database should be empty"
  end

  test "should create a new note" do
    create_note(title, body)
  end

  test "should create a new note and access it by it's id" do
    note = create_note(title, body)

    get "#{api_v1_notes_url}/#{note["id"]}"
    assert_response :success, "an error occurred when getting the note with id=#{note["id"]}"

    note = @response.parsed_body
    assert_note_has_title_and_body(note, title, body)
  end

  test "should create multiple new notes and get them all" do
    nb_notes = 10
    (1..nb_notes).each { |i|
      create_note("#{title} ##{i}", body)
    }

    get api_v1_notes_url, as: :json
    assert_response :success, "an error occurred when getting the notes"

    notes = @response.parsed_body
    assert_not_nil notes, "the database should not be empty"
    assert_equal nb_notes, notes.length, "there should be #{nb_notes} notes but #{notes.length} notes found"
  end

  test "should create a note then update the title and the body" do
    new_title = title + " updated"
    new_body = body + " updated"

    note = create_note(title, body)

    put "#{api_v1_notes_url}/#{note["id"]}",
        params: { title: new_title, body: new_body },
        as: :json
    assert_response :success, "an error occurred when updating the note with id=#{note["id"]}"

    note = @response.parsed_body
    assert_note_has_title_and_body(note, new_title, new_body)
  end

  private

  def clear_db
    get api_v1_notes_url, as: :json
    assert_response :success, "an error occurred when getting the notes"

    @response.parsed_body.each { |note|
      assert_not_nil note["id"], "the note as no id"
      delete "#{api_v1_notes_url}/#{note["id"]}"
      assert_response :success, "an error occurred when deleting note with id=#{note["id"]}"
    }
  end

  def title
    "My new awesome note !"
  end

  def body
    "What a relief to use this app ! So simple, much WOW"
  end

  def assert_note_has_title_and_body(note, title, body)
    assert_not_nil note, "no note was returned"
    assert_equal title, note['title'], "note title does not match."
    assert_equal body, note['body'], "note does not contain a body."
  end

  def create_note(title, body)
    post api_v1_notes_url,
         params: { title: title, body: body },
         as: :json
    assert_response :success, "an error occurred when posting the note"

    note = @response.parsed_body
    assert_note_has_title_and_body(note, title, body)

    note
  end
end
