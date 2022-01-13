class Api::V1::NotesController < ApplicationController

  before_action :authentication

  # GET /api/v1/structure
  def structure
    user = logged_in_user
    if user
      render json: user.folders.to_json(include: [notes: {include: :tags, except: [:body]}]), status: :ok
    else
      raise NotFoundError.new("user not found")
    end
  end

  # GET /api/v1/notes/:id
  def show
    note = Note.find(params[:id])

    verify_ownership note

    render json: note
  end

  # POST /api/v1/notes
  def create
    begin
      folder = Folder.find(params[:folder_id])
    rescue ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

    user = logged_in_user
    unless user.own_folder? folder
      raise BadRequestError.new("user doesn't own the folder")
    end

    note = Note.new(note_params)

    if note.save
      render json: note.to_json(include: :tags), status: :ok
    else
      raise BadRequestError.new("unable to create note")
    end
  end

  # PUT /api/v1/notes/:id
  def update
    begin
      note = Note.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

    verify_ownership note

    if params.has_key?(:folder_id)
      begin
        folder = Folder.find(params[:folder_id])
      rescue ActiveRecord::RecordNotFound => e
        raise BadRequestError.new(e)
      end

      user = logged_in_user
      unless user.own_folder? folder
        raise BadRequestError.new("user doesn't own the folder")
      end
    end

    if note
      note.update(note_params)
      render json: note
    else
      raise BadRequestError.new("unable to update note")
    end
  end

  # DELETE /api/v1/notes/:id
  def destroy
    begin
      note = Note.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

    verify_ownership note

    if note
      note.destroy
      render json: {message: "Note deleted"}, status: :ok
    end
  end

  # GET /api/v1/notes/:id/shared_notes
  def get_all_shared_notes_by_note
    begin
      note = Note.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

    verify_ownership note

    render json: note.shared_notes, status: :ok
  end

  private

  def note_params
    params.require(:note).permit(:title, :body, :folder_id)
  end

  def verify_ownership(note)
    user = logged_in_user
    unless user.own_note? note
      raise BadRequestError.new("user doesn't own the note")
    end
  end
end