class Api::V1::TagsController < ApplicationController

  # Controller responsible for handling CRUD on tags

  before_action :authentication

  # GET /api/v1/tags
  # Display all the tags of the user
  def index
    # Return all tags corresponding to the user
    user = logged_in_user
    render json: Tag.joins(note: :folder).where(folders: {user_id: user.id}), status: :ok
  end

  # GET /api/v1/tags/:id
  # Display at tag identified by his ID
  def show
    # Find the tag, raise an error if it doesn't exists
    begin
      tag = Tag.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      raise NotFoundError.new(e.message)
    end

    # Verify tag's user
    verify_ownership tag

    # Return the tag as JSON
    render json: tag, status: :ok
  end

  # POST /api/v1/tags
  # Create a new tag, needs parameters: note_id, title
  def create
    # Find corresponding note
    begin
      note = Note.find(params[:note_id])
    rescue ActiveRecord::RecordNotFound => e
      raise NotFoundError.new(e.message)
    end

    # Check if the note belongs to the user
    user = logged_in_user
    unless user.own_note? note
      raise BadRequestError.new("user doesn't own the note")
    end

    # Create the tag
    tag = Tag.new(note_id: note.id, title: params[:title])

    # Save the new tag in database
    if tag.save
      render json: tag, status: :created
    else
      raise BadRequestError.new(tag.errors.full_messages)
    end
  end

  # PUT/PATCH /api/v1/tags/:id
  # Update a tag's properties
  def update
    # Find the tag
    begin
      tag = Tag.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      raise NotFoundError.new(e.message)
    end

    # Find the note
    begin
      Note.find(params[:note_id])
    rescue ActiveRecord::RecordNotFound => e
      raise NotFoundError.new(e.message)
    end

    # Check if the tag belongs to the user
    verify_ownership tag

    # Update the tag's properties
    if tag
      tag.update(tag_params)
      verify_ownership tag
      render json: tag
    else
      raise BadRequestError.new("cannot update tag")
    end
  end

  # DELETE /api/v1/tags/:id
  # Delete a tag
  def destroy
    # Find the tag
    begin
      tag = Tag.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      raise NotFoundError.new(e.message)
    end

    # Check if the tag belongs to the user
    verify_ownership tag

    # Delete the tag
    if tag
      tag.destroy
      render json: {message: "tag deleted"}, status: :ok
    end
  end

  private

  # Define authorized arguments in the body
  def tag_params
    params.require(:tag).permit(:title, :note_id)
  end

  # Function responsible for verifying if the user owns the tag
  def verify_ownership(tag)
    # Get the user
    user = logged_in_user

    # Check if the user owns the note
    unless user.own_note? tag.note
      raise BadRequestError.new("user doesn't own tag")
    end
  end
end
