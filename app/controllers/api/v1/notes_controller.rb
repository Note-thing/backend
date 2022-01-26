class Api::V1::NotesController < ApplicationController

  before_action :authentication

  # GET /api/v1/structure
  # Return the user's folders
  def structure
    # Return the user's folders
    user = logged_in_user
    if user
      render json: user.folders.to_json(include: [notes: {include: :tags, except: [:body]}]), status: :ok
    else
      raise NotFoundError.new("user not found")
    end
  end

  # GET /api/v1/notes/unlock/:id
  # Unlocks a note
  def unlock
    # Find the note
    begin
      note = Note.find(params[:id])
    rescue  ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

    # Check if the user owns the note
    verify_ownership note

    # Unlock the note and it's famils (copies / parent)
    note.lock = false
    note.set_family_to(false)
    note.save

    head :no_content
  end

  # GET /api/v1/notes/:id
  # Display a note
  def show
    # Find the note
    begin
      note = Note.find(params[:id])
    rescue  ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

    # Check if the user owns the note
    verify_ownership note

    # If the note isn't read only or locked, lock it's family
    unless note.read_only
      unless note.lock
        unless note.read_only
          note.set_family_to true
          note.touch
          note.save
        end
      end
    end

    # If the note isn't read only and it has been locked for more than a certain time, unlock the note and lock the family
    unless note.read_only
      unless note.has_family_been_used_recently
        note.set_family_to true
        note.lock = false
        note.save
      end
    end

    # render json: {note: note.as_json(except: [:lock])}, status: :ok
    # Return the note
    render json: note.to_json(include: :tags), status: :ok
  end

  # GET /api/v1/notes/read_only/:id
  # Display a note but don't acquire a lock on it
  def read_only
    # Find the note
    begin
      note = Note.find(params[:id])
    rescue  ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

    # Check if the user owns the note
    verify_ownership note

    # Lock the note for the user but not in database
    note.lock = true
    # ! do not save !

    # Display the note
    render json: note.to_json(include: :tags), status: :ok
  end

  # POST /api/v1/notes
  # Create a new note, need the parameters defined in note_params
  def create

    # Find the folder
    begin
      folder = Folder.find(params[:folder_id])
    rescue ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

    # Check if the user owns the folder
    user = logged_in_user
    unless user.own_folder? folder
      raise BadRequestError.new("user doesn't own the folder")
    end

    # Create the new note with the parameters
    note = Note.new(note_params)
    note.lock = false

    # Save the new note
    if note.save
      render json: note.to_json(include: :tags), status: :ok
    else
      raise BadRequestError.new("unable to create note")
    end
  end

  # PUT /api/v1/notes/:id
  # Update a note, requires parameters defined in note_params
  def update
    # Find the note
    begin
      note = Note.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

    # Verify if the user owns the note
    verify_ownership note

    # Check if the note is locked or read only
    if note.lock
      raise UnprocessableEntityError.new("note is locked")
    end

    if note.read_only
      raise UnprocessableEntityError.new("note is on read only")
    end

    # Check if the parameters contain folder_id
    if params.has_key?(:folder_id)
      # Find the folder
      begin
        folder = Folder.find(params[:folder_id])
      rescue ActiveRecord::RecordNotFound => e
        raise BadRequestError.new(e)
      end

      # Check if the user owns the folder
      user = logged_in_user
      unless user.own_folder? folder
        raise BadRequestError.new("user doesn't own the folder")
      end
    end

    # Update the note
    if note
      # https://apidock.com/rails/ActiveRecord/Persistence/touch
      note.touch
      note.update(note_params)

      # If it's a mirror, update the parent
      if note.reference_note and note.read_only == false
        note.copy_to_parent
      end

      # If it's a parent, update it's children
      note.update_children

      render json: note.to_json(include: :tags), status: :ok
    else
      raise BadRequestError.new("unable to update note")
    end
  end

  # DELETE /api/v1/notes/:id
  # Delete a note
  def destroy
    # Find the note
    begin
      note = Note.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

    # Check if the user owns the note
    verify_ownership note

    # Check if the note is locked
    if note.lock
      raise UnprocessableEntityError.new("note is locked, cannot be deleted")
    end

    # Remove family link and copies
    note.set_family_to false
    note.remove_mirror_to_family
    note.remove_copies

    # Delete the note
    if note
      note.destroy
      render json: {message: "Note deleted"}, status: :ok
    end
  end

  # GET /api/v1/notes/:id/shared_notes
  # Get all the shared notes of a note
  def get_all_shared_notes_by_note
    # Find the note
    begin
      note = Note.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

    # Check if the user owns the note
    verify_ownership note

    # Display the shared_notes
    render json: note.shared_notes, status: :ok
  end

  private


  def note_params
    params.require(:note).permit(:title, :body, :folder_id)
  end

  # Function checking if the user owns the note
  def verify_ownership(note)
    user = logged_in_user
    unless user.own_note? note
      raise BadRequestError.new("user doesn't own the note")
    end
  end
end