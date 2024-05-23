require 'json_web_token_service'

module Api
  module V1
    class TodosController < ApplicationController
      before_action :set_todo, only: [:show, :update, :destroy]

      def index
        @todos = current_user.todos.order(:order)
        render json: @todos
      end

      def create
        @todo = current_user.todos.build(todo_params)
        @todo.order = current_user.todos.maximum(:order).to_i + 1

        if @todo.save
          render json: @todo, status: :created
        else
          render json: @todo.errors, status: :unprocessable_entity
        end
      end

      def update
        if @todo.update(todo_params)
          render json: @todo
        else
          render json: @todo.errors, status: :unprocessable_entity
        end
      end

      def update_order
        ActiveRecord::Base.transaction do
          params[:order].each_with_index do |id, index|
            current_user.todos.find(id).update!(order: index)
          end
        end
        head :no_content
      end

      def destroy
        @todo.destroy
        head :no_content
      end

      def clear
        current_user.todos.delete_all
      end

      private

      def set_todo
        @todo = current_user.todos.find(params[:id])
      end

      def todo_params
        params.require(:todo).permit(:order, :description, :finished)
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
