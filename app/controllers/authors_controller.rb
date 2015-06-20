class AuthorsController < ApplicationController
  def index
    @authors = Author.get_list_from_user_with_shelf params[:user_id], 'read'
  end
  
  def show
    gender = Author.get_gender params[:author_id]
    render json: gender
  end
end
