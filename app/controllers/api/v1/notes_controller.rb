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

  # GET /api/v1/notes/unlock/:id
  def unlock
    begin
      note = Note.find(params[:id])
    rescue  ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

    verify_ownership note

    note.lock = false
    note.set_family_to(false)
    note.save

    head :no_content
  end

  # GET /api/v1/notes/:id
  def show
    begin
      note = Note.find(params[:id])
    rescue  ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

    verify_ownership note

    unless note.read_only
      unless note.lock
        # nested if => pas incroyable, mais a le mérite de fonctionner
        unless note.read_only
          note.set_family_to true
          note.touch
        end
      end
    end

    unless note.read_only
      if note.has_not_been_used_recently
        note.set_family_to true
        note.lock = false
        note.save
      end
    end

    #if note.reference_note
    #  note.copy_from_parent
    #end

    # render json: {note: note.as_json(except: [:lock])}, status: :ok
    render json: note, status: :ok
  end

  # GET /api/v1/notes/read_only/:id
  def read_only
    begin
      note = Note.find(params[:id])
    rescue  ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

    note.lock = true
    # ! do not save !

    render json: note, status: :ok
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
    note.lock = false

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

    if note.lock
      raise UnprocessableEntityError.new("note is locked")
    end

    if note.read_only
      raise UnprocessableEntityError.new("note is on read only")
    end

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
      # https://apidock.com/rails/ActiveRecord/Persistence/touch
      note.touch
      note.update(note_params)

      if note.reference_note and note.read_only == false
        note.copy_to_parent
      end

      note.update_children

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

    if note.lock
      raise UnprocessableEntityError.new("note is locked, cannot be deleted")
    end

    note.set_family_to false
    note.remove_mirror_to_family
    note.remove_copies

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