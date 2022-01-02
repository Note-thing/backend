class Api::V1::TagsController < ApplicationController

  before_action :authentication

  def index
    user = logged_in_user

    # Cette ligne, c'est 10% de mes capacités.
    render json: Tag.joins(notes: :folder).where(folders: {user_id: user.id}), status: :ok
  end

  def show
    tag = Tag.find(params[:id])
    render json: tag, status: :ok
  end

  def create
    begin
      note = Note.find(params[:note_id])
    rescue ActiveRecord::RecordNotFound => e
      raise NotFoundError.new(e.message)
    end

    tag = Tag.new(tag_params)

    if tag.save
      tag.note_tags.create({note_id: note.id})
      render json: tag, status: :created
    else
      raise BadRequestError.new(tag.errors.full_messages)
    end
  end

  def update
    tag = Tag.find(params[:id])
    if tag
      tag.update(note_params)
      render json: tag
    else
      raise BadRequestError.new("cannot update tag")
    end
  end

  def destroy
    tag = Tag.find(params[:id])
    if tag
      tag.destroy
      render json: {message: "tag deleted"}, status: :ok
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:title)
  end

end
