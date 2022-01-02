
require 'securerandom'
class Api::V1::SharedNotesController < ApplicationController

  # GET /api/v1/shared_notes/:id
  def show
    shared_note = SharedNote.find(params[:id])
    render json: shared_note
  end

  # POST /api/v1/shared_notes
  def create
    # TODO: s'assurer que la note appartient à l'utilisateur connecté
    note = Note.find(params[:id])

    shared_note = SharedNote.new
    shared_note.title = note.title
    shared_note.body = note.body
    shared_note.note_id = note.id
    shared_note.uuid = SecureRandom.uuid
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