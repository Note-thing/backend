
require 'securerandom'
class Api::V1::SharedNotesController < ApplicationController

  # Controller responsible for handling creation, delete and copy of a shared_note

  before_action :authentication

  # GET /api/v1/shared_notes/:id
  # Display the shared_note properties
  def show
    shared_note = SharedNote.find(params[:id])
    render json: shared_note
  end

  # POST /api/v1/shared_notes
  # Create a new shared_note, uses parameters : note_id, sharing_type
  def create
    # Find the note
    begin
      note = Note.find(params[:note_id])
    rescue ActiveRecord::RecordNotFound => e
      raise NotFoundError.new(e.message)
    end

    # Check if the user owns the note
    unless logged_in_user.own_note? note
      raise BadRequestError.new("user doesn't own the note")
    end

    # Check if the sharing_type is valid
    unless params[:sharing_type].present?
      raise BadRequestError.new("sharing type not present")
    end

    unless SharedNote.share_type.include?(params[:sharing_type])
      raise BadRequestError.new("sharing type not valid")
    end

    # Check if we try to copy a copy
    if note.reference_note != nil
      raise UnprocessableEntityError.new("cannot copy a copied note")
    end

    # Create the new shared_note
    shared_note = SharedNote.new
    shared_note.title = note.title
    shared_note.body = note.body
    shared_note.note_id = note.id
    shared_note.uuid = SecureRandom.uuid
    shared_note.sharing_type = params[:sharing_type]

    # Save the shared note and render it's properties
    if shared_note.save
      render json: shared_note, status: :created
    else
      raise BadRequestError.new("unable to create a shared note")
    end
  end

  # DELETE /api/v1/shared_notes/:id
  # Delete a shared_note
  def destroy
    # Find the shared_note
    shared_note = SharedNote.find(params[:id])
    if shared_note
      shared_note.destroy
      render json: {message: "shared note deleted"}, status: :ok
    end
  end

  # POST /api/v1/shared_notes/:uuid/copy
  # Use a shared_note to get a copied note, needs params : folder_id
  def copy
    # Check if the shared_note exists
    shared_note = SharedNote.find_by(uuid: params[:uuid])
    unless shared_note
      #render json: {error: 'note not found', status: 404}, status: 404
      raise NotFoundError.new("note not found")
    end

    # Check if the folder exists
    begin
      folder = Folder.find(params[:folder_id])
    rescue ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

    # Check if the user exists and owns the folder
    user = logged_in_user
    unless user.own_folder? folder
      raise BadRequestError.new("user doesn't own the folder")
    end

    # Create the copy
    note = Note.new
    note.folder_id = params[:folder_id]
    note.title = shared_note.title
    note.body = shared_note.body
    note.lock = false

    # Case if we want a read only copy
    if shared_note.sharing_type == SharedNote::READ_ONLY
      note.reference_note = shared_note.note_id
      note.read_only = true
      # Case if we want a fully shared note
    elsif shared_note.sharing_type == SharedNote::MIRROR
      note.reference_note = shared_note.note_id
      note.read_only = false
      note.has_mirror = true
      note.lock = true

      begin
        parent = Note.find(shared_note.note_id)
      rescue ActiveRecord::RecordNotFound
        raise BadRequestError.new("unable to find parent")
      end
      parent.has_mirror = true
      unless parent.save
        raise BadRequestError.new("Unable to update parent")
      end

      # Case if we want to make "real" copy
    elsif shared_note.sharing_type == SharedNote::COPY_CONTENT
      note.read_only = false
    else
      unless SharedNote.share_type.include?(shared_note.sharing_type)
        shared_note.destroy
        raise UnprocessableEntityError.new("Failed to create note from shared note")
      end
    end


    # Save the new note
    if note.save
      shared_note.destroy
      render json: note, status: :ok
    else
      #render json: {error: 'Unable to copy the note', status: 422}, status: 422
      raise UnprocessableEntityError.new(note.errors.full_messages)
    end

  end

  private

  def shared_note_params
    params.require(:shared_notes).permit(:noteId, :title, :body, )
  end
end