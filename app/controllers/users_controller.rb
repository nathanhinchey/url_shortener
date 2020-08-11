class UsersController < ApplicationController
  def create
    user = User.create(email: params[:email], password: params[:password])
    if user.valid?
      render json: { email: user.email }
    else
      render json: { errors: user.errors.messages }, status: :unprocessable_entity
    end
  end
end
