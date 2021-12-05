class Api::V1::NotesController < ApplicationController

  before_action :authentication

  # GET /api/v1/structure/:user_id
  def structure
    user = User.find(params[:user_id])
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

  # DELETE /api/v1/notes/:id
  def destroy
    @note = Note.find(params[:id])
    if @note
      @note.destroy
      render json: {message: "Note deleted"}, status: 200
    end
  end

  def addtag
    @note = Note.find(add_tag_params[:note_id])
    @tag = Tag.find(add_tag_params[:tag_id])
    if @note && @tag
      @note_tag = NoteTag.new(add_tag_params)
      if @note_tag.save
        render json: @note_tag
      else
        render json: {message: "Erreur..."}, status: 400
      end
    end
  end

  # TODO : make the delete
  def delTag
    @note_tag = NoteTag.find()
  end


  private

  def note_params
    params.require(:note).permit(:title, :body, :folder_id)
  end

  def add_tag_params
    params.require(:note_tag).permit(:tag_id, :note_id)
  end


end
