class Api::V1::NotesController < ApplicationController

  # GET /api/v1/notes
  def index
    @notes = Note.all
    render json: @notes
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
      render error: {error: 'Unable de créer une note'}, status: 400
    end
  end

  # PUT /api/v1/notes/:id
  def update
    @note = Note.find(params[:id])
    if @note
      @note.update(note_params)
      render json: @note
    else
      render error: {error: 'Unable de update la note'}, status: 400
    end
  end

  # DELETE /api/v1/:id
  def destroy
    @note = Note.find(params[:id])
    if @note
      @note.destroy
      render json: {message: "Note deleted"}, status: 200
    end
  end


  private

  def note_params
    params.require(:note).permit(:title, :body)
  end


end
