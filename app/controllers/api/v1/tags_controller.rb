class Api::V1::TagsController < ApplicationController

  before_action :authentication

  def index
    @tags = Tag.all
    render json: @tags
  end

  def show
    @tag = Tag.find(params[:id])
    render json: @tag
  end

  def create
    @tag = Tag.new(tag_params)
    if @tag.save
      render json: @tag
    else
      render error: {error: 'Impossible de créer un tag'}, status: 400
    end
  end

  def update
    @tag = Tag.find(params[:id])
    if @tag
      @tag.update(note_params)
      render json: @tag
    else
      render error: {error: 'Impossible de modifier le tag'}, status: 400
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    if @tag
      @tag.destroy
      render json: {message: "Tag supprimé"}, status: 200
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:title)
  end
end
