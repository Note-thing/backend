class Api::V1::FoldersController < ApplicationController

  # Controller handling CRUD operations for folder

  before_action :authentication

  # POST /api/v1/folders
  # Create a new folder, needs parameters defiend in folder_params
  def create
    # Create the folder
    folder = Folder.new(folder_params)
    folder.user = logged_in_user

    # Save the folder
    if folder.save
      render json: folder.to_json(include: :notes), status: :created
    else
      raise BadRequestError.new(folder.errors.full_messages)
    end
  end

  # PUT /api/v1/folders/:id
  # Update a folder properties, require parameters defined in folder_params
  def update
    # Find the folder
    begin
      folder = Folder.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

    # Verify if the user owns the folder
    verify_ownership folder

    folder.user = logged_in_user

    # Update the folder with new parameters
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
  # Delete a folder
  def destroy
    # Find the folder
    begin
      folder = Folder.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

    # Check if the user owns the folder
    verify_ownership folder

    # Delete the folder
    if folder
      folder.destroy
      render json: {message: "Folder deleted"}, status: :ok
    else
      raise NotFoundError.new("folder not found")
    end
  end


  # GET /api/v1/folders
  # Display all folders belonging to the user
  def get
    # Get the user
    user = logged_in_user

    # Display the folders
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

  # Function checking if the user owns a folder
  def verify_ownership(folder)
    user = logged_in_user
    unless user.own_folder? folder
      raise BadRequestError.new("user doesn't own folder")
    end
  end

end
