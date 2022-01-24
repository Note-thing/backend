
require 'securerandom'
class Api::V1::SharedNotesController < ApplicationController

  before_action :authentication

  # GET /api/v1/shared_notes/:id
  def show
    shared_note = SharedNote.find(params[:id])
    render json: shared_note
  end

  # POST /api/v1/shared_notes
  def create
    begin
      note = Note.find(params[:note_id])
    rescue ActiveRecord::RecordNotFound => e
      raise NotFoundError.new(e.message)
    end

    unless logged_in_user.own_note? note
      raise BadRequestError.new("user doesn't own the note")
    end

    unless params[:sharing_type].present?
      raise BadRequestError.new("sharing type not present")
    end

    unless SharedNote.share_type.include?(params[:sharing_type])
      raise BadRequestError.new("sharing type not valid")
    end

    if note.reference_note != nil
      raise UnprocessableEntityError.new("cannot copy a copied note")
    end

    shared_note = SharedNote.new
    shared_note.title = note.title
    shared_note.body = note.body
    shared_note.note_id = note.id
    shared_note.uuid = SecureRandom.uuid
    shared_note.sharing_type = params[:sharing_type]

    if shared_note.save
      render json: shared_note, status: :created
    else
      raise BadRequestError.new("unable to create a shared note")
    end
  end

  # DELETE /api/v1/shared_notes/:id
  def destroy
    shared_note = SharedNote.find(params[:id])
    if shared_note
      shared_note.destroy
      render json: {message: "shared note deleted"}, status: :ok
    end
  end

  # POST /api/v1/shared_notes/:uuid/copy
  def copy
    shared_note = SharedNote.find_by(uuid: params[:uuid])
    unless shared_note
      #render json: {error: 'note not found', status: 404}, status: 404
      raise NotFoundError.new("note not found")
    end

    begin
      folder = Folder.find(params[:folder_id])
    rescue ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

    user = logged_in_user
    unless user.own_folder? folder
      raise BadRequestError.new("user doesn't own the folder")
    end

    note = Note.new
    note.folder_id = params[:folder_id]
    note.title = shared_note.title
    note.body = shared_note.body

    if shared_note.sharing_type == SharedNote::READ_ONLY
      note.reference_note = shared_note.note_id
      note.read_only = true
    elsif shared_note.sharing_type == SharedNote::MIRROR
      note.reference_note = shared_note.note_id
      note.read_only = false
      note.has_mirror = true

      begin
        parent = Note.find(shared_note.note_id)
      rescue ActiveRecord::RecordNotFound
        raise BadRequestError.new("unable to find parent")
      end
      parent.has_mirror = true
      unless parent.save
        raise BadRequestError.new("Unable to update parent")
      end


    elsif shared_note.sharing_type == SharedNote::COPY_CONTENT
      note.read_only = false
    else
      unless SharedNote.share_type.include?(shared_note.sharing_type)
        shared_note.destroy
        raise UnprocessableEntityError.new("Failed to create note from shared note")
      end
    end

    note.lock = false

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