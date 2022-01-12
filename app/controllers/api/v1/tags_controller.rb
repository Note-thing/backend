class Api::V1::TagsController < ApplicationController

  before_action :authentication

  def index
    user = logged_in_user

    # Cette ligne, c'est 15% de mes capacités.
    render json: Tag.joins(note: :folder).where(folders: {user_id: user.id}), status: :ok
  end

  def show
    begin
      tag = Tag.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      raise NotFoundError.new(e.message)
    end

    verify_ownership tag

    render json: tag, status: :ok
  end

  def create
    begin
      note = Note.find(params[:note_id])
    rescue ActiveRecord::RecordNotFound => e
      raise NotFoundError.new(e.message)
    end

    user = logged_in_user
    unless user.own_note? note
      raise BadRequestError.new("user doesn't own the note")
    end

    tag = Tag.new(note_id: note.id, title: params[:title])

    if tag.save
      render json: tag, status: :created
    else
      raise BadRequestError.new(tag.errors.full_messages)
    end
  end

  def update
    begin
      tag = Tag.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      raise NotFoundError.new(e.message)
    end

    begin
      Note.find(params[:note_id])
    rescue ActiveRecord::RecordNotFound => e
      raise NotFoundError.new(e.message)
    end

    verify_ownership tag

    if tag
      tag.update(tag_params)
      verify_ownership tag
      render json: tag
    else
      raise BadRequestError.new("cannot update tag")
    end
  end

  def destroy
    begin
      tag = Tag.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      raise NotFoundError.new(e.message)
    end

    verify_ownership tag

    if tag
      tag.destroy
      render json: {message: "tag deleted"}, status: :ok
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:title, :note_id)
  end

  def verify_ownership(tag)
    user = logged_in_user

    unless user.own_note? tag.note
      raise BadRequestError.new("user doesn't own tag")
    end
  end


end
