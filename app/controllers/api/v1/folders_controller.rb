class Api::V1::FoldersController < ApplicationController

  before_action :authentication

  # POST /api/v1/folders
  def create
    folder = Folder.new(folder_params)
    folder.user = logged_in_user

    if folder.save
      render json: folder.to_json(include: :notes), status: :created
    else
      render json: {error: folder.errors.full_messages }, status: :bad_request
    end
  end

  # PUT /api/v1/folder/:id
  def update
    folder = Folder.find(params[:id])
    folder.user = logged_in_user

    if folder
      if folder.update(folder_params)
        render json: folder, status: :ok
      else
        render json: {error: folder.errors.full_messages }, status: :bad_request
      end
    else
      render json: {error: "Folder not found"}, status: :not_found
    end
  end

  # DELETE /api/v1/folders/:id
  def destroy
    folder = Folder.find(params[:id])
    if folder
      folder.destroy
      render json: {message: "Folder deleted"}, status: :ok
    else
      render json: {error: "Folder not found"}, status: :not_found
    end
  end


  # GET /api/v1/folders
  def get
    user = logged_in_user

    if user
      render json: user.folders, status: :ok
    else
      render json: {error: "User not found"}, status: :not_found
    end

  end

  private

  def folder_params
    params.require(:folder).permit(:title)
  end

end
