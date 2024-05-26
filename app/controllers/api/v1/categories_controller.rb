require 'json_web_token_service'

module Api
  module V1
    class CategoriesController < ApplicationController
      def index
        @categories = current_user.categories
        render json: @categories
      end

      def create
        if params.key?(:category)
          @category = current_user.categories.build(category_params)
          if @category.save
            render json: @category, status: :created
          else
            render json: @category.errors, status: :unprocessable_entity
          end
        else
          render json: { error: 'Missing category parameter' }, status: :bad_request
        end
      end

      def destroy
        @category = current_user.categories.find(params[:id])
        @category.destroy
        head :no_content
      end

      private

      def category_params
        category_params = params.require(:category)
        category_params.is_a?(String) ? { name: category_params } : category_params.permit(:name)
      end

      def current_user
        return @current_user if @current_user

        header = request.headers['Authorization']
        token = header.split(' ').last if header
        decoded = JsonWebTokenService.decode(token)
        @current_user = User.find(decoded[:user_id])
      rescue ActiveRecord::RecordNotFound, StandardError
        nil
      end
    end
  end
end