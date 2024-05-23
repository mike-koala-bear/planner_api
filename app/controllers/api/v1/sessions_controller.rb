require 'json_web_token_service'

class Api::V1::SessionsController < ApplicationController
  def create
    @user = User.find_by(email: session_params[:email])

    if @user&.authenticate(session_params[:password])
      token = JsonWebTokenService.encode(user_id: @user.id)
      render json: { user: @user, token: token, message: 'Login successful' }, status: :ok
    else
      render json: { errors: ['Invalid email or password'] }, status: :unauthorized
    end
  end

  private

  def session_params
    params.require(:user).permit(:email, :password)
  end
end
