
require 'securerandom'
class Api::V1::SharedNotesController < ApplicationController

  before_action :authentication, only: [:create]

  # GET /api/v1/shared_notes/:id
  def show
    shared_note = SharedNote.find(params[:id])
    render json: shared_note
  end

  # POST /api/v1/shared_notes
  def create
    user = logged_in_user
    note = Note.find(params[:id])
    
    if note.folder.user.id != user.id
      raise BadRequestError("unable to create a shared note")
    end

    sharedNote = SharedNote.new()
    sharedNote.title = note.title
    sharedNote.body = note.body
    sharedNote.note_id = note.id
    sharedNote.uuid = SecureRandom.uuid
    if sharedNote.save
      render json: sharedNote
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

  # GET /api/v1/shared_notes/:uuid/copy
  def copy
    shared_note = SharedNote.find_by(uuid: params[:uuid])
    unless shared_note
      #render json: {error: 'note not found', status: 404}, status: 404
      raise NotFoundError.new("note not found")
    end

    note = Note.new
    note.title = shared_note.title
    note.body = shared_note.body
    note.folder_id = params[:folderId]
    if note.save
      render json: note
    else
      #render json: {error: 'Unable to copy the note', status: 422}, status: 422
      raise UnprocessableEntityError.new("unable to copy the note")
    end

  end

  private

  def shared_note_params
    params.require(:shared_notes).permit(:noteId, :title, :body, )
  end
end