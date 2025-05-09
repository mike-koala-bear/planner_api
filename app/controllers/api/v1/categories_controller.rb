require 'json_web_token_service'

module Api
  module V1
    class CategoriesController < ApplicationController
      def index
        @categories = current_user.categories.includes(:tasks)
        render json: @categories, include: :tasks
      end

      def create
        if params.key?(:category)
          @category = current_user.categories.build(category_params)
          # @category = Category.build(category_params.merge(user_id: User.first.id))
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
        @category = Category.find(params[:id])
        @category.destroy
        head :no_content
      end

      def update_size
        category = Category.find(params[:category_id])
        if category.update(category_params)
          render json: category
        else
          render json: category.errors, status: :unprocessable_entity
        end
      end

      def update
        category = Category.find(params[:id])
        if category.update(category_params)
          render json: category
        end
        head :no_content
      end

def update_sorting_mode
  category = Category.find_by(id: params[:id])

  if category.nil?
    render json: { error: "Category not found" }, status: :not_found
    return
  end

  # Only update sorting mode without changing task order
  if category.update(manual_sorting: params[:manual_sorting])
    render json: {
      id: category.id,
      manual_sorting: category.manual_sorting,
      tasks: category.tasks.order(:order) # Ensure tasks keep their order
    }, status: :ok
  else
    render json: { error: "Failed to update sorting mode" }, status: :unprocessable_entity
  end
end




      private

      def category_params
        params.require(:category).permit(:name, :width, :height, :manual_sorting)

        # category_params = params.require(:category)
        # category_params.is_a?(String) ? { name: category_params } : category_params.permit(:name, :width, :height)
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
