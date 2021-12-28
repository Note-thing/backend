class Api::V1::NotesController < ApplicationController

  before_action :authentication

  # GET /api/v1/structure
  def structure
    user = logged_in_user
    if user
      render json: user.folders.to_json(include: [:notes => {include: :tags}] )
    else
      render json: {error: "User not existant"}, status: :not_found
    end
  end

  # GET /api/v1/notes/:id
  def show
    @note = Note.find(params[:id])
    render json: @note
  end

  # POST /api/v1/notes
  def create
    @note = Note.new(note_params)
    if @note.save
      render json: @note
    else
      render json: {error: 'Unable de créer une note'}, status: 400
    end
  end

  # PUT /api/v1/notes/:id
  def update
    @note = Note.find(params[:id])
    if @note
      @note.update(note_params)
      render json: @note
    else
      render json: {error: 'Unable de update la note'}, status: 400
    end
  end

  # DELETE /api/v1/notes/:id
  def destroy
    @note = Note.find(params[:id])
    if @note
      @note.destroy
      render json: {message: "Note deleted"}, status: 200
    end
  end

  # GET /api/v1/notes/:id/shared_notes
  def getAllSharedNotesByNote
    render json: Note.find(params[:id]).shared_notes
  end

  private

  def note_params
    params.require(:note).permit(:title, :body)
  end
end
