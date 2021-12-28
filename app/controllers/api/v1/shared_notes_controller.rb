
require 'securerandom'
class Api::V1::SharedNotesController < ApplicationController

  # GET /api/v1/shared_notes/:id
  def show
    @sharedNote = SharedNote.find(params[:id])
    render json: @sharedNote
  end

  # POST /api/v1/shared_notes
  def create
    @note = Note.find(params[:id])

    @sharedNote = SharedNote.new()
    @sharedNote.title = @note.title
    @sharedNote.body = @note.body
    @sharedNote.note_id = @note.id
    @sharedNote.uuid = SecureRandom.uuid
    if @sharedNote.save
      render json: @sharedNote
    else
      render error: {error: 'Not able to create a shared note'}, status: 400
    end
  end


  # DELETE /api/v1/shared_notes/:id
  def destroy
    @sharedNote = SharedNote.find(params[:id])
    if @sharedNote
      @sharedNote.destroy
      render json: {message: "shared note deleted"}, status: 200
    end
  end

  # GET /api/v1/shared_notes/:uuid/copy
  def copy
    sharedNote = SharedNote.find_by(uuid: params[:uuid])
    unless sharedNote
      render json: {error: 'note not found', status: 404}, status: 404
      return
    end


    note = Note.new()
    note.title = sharedNote.title
    note.body = sharedNote.body
    note.folder_id = params[:folderId]
    if note.save
      render json: note
    else
      render json: {error: 'Unable to copy the note', status: 422}, status: 422
    end

  end

  private

  def shared_note_params
    params.require(:shared_notes).permit(:noteId, :title, :body, )
  end
end