class Api::V1::FoldersController < ApplicationController

  before_action :authentication

  # POST /api/v1/folders
  def create
    folder = Folder.new(folder_params)
    folder.user = logged_in_user

    if folder.save
      render json: folder.to_json(include: :notes), status: :created
    else
      raise BadRequestError.new(folder.errors.full_messages)
    end
  end

  # PUT /api/v1/folder/:id
  def update
    begin
      folder = Folder.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

    verify_ownership folder

    folder.user = logged_in_user

    if folder
      if folder.update(folder_params)
        render json: folder, status: :ok
      else
        raise BadRequestError.new(folder.errors.full_messages)
      end
    else
      raise NotFoundError.new("folder not found")
    end
  end

  # DELETE /api/v1/folders/:id
  def destroy
    begin
      folder = Folder.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

    verify_ownership folder

    if folder
      folder.destroy
      render json: {message: "Folder deleted"}, status: :ok
    else
      raise NotFoundError.new("folder not found")
    end
  end


  # GET /api/v1/folders
  def get
    user = logged_in_user

    if user
      render json: user.folders, status: :ok
    else
      raise NotFoundError.new("user not found")
    end

  end

  private

  def folder_params
    params.require(:folder).permit(:title)
  end

  def verify_ownership(folder)
    user = logged_in_user
    unless user.own_folder? folder
      raise BadRequestError.new("user doesn't own folder")
    end
  end

end
