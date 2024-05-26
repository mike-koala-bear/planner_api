require 'json_web_token_service'

module Api
  module V1
    class TasksController < ApplicationController
      before_action :set_task, only: [:show, :update, :destroy]
      before_action :set_category, only: [:create, :update]

      def index
        @tasks = current_user.tasks.includes(:category).order(:order)
        # @tasks = Task.includes(:category).order(:order)
        render json: @tasks, include: :category
      end

      def create
        @task = current_user.tasks.build(task_params)
        @task.order = current_user.tasks.maximum(:order).to_i + 1
        @task.category = @category

        if @task.save
          render json: @task, status: :created, include: :category
        else
          render json: @task.errors, status: :unprocessable_entity
        end
      end

      def update
        if @task.update(task_params)
          render json: @task, include: :category
        else
          render json: @task.errors, status: :unprocessable_entity
        end
      end

      def update_order
        ActiveRecord::Base.transaction do
          params[:order].each_with_index do |id, index|
            current_user.tasks.find(id).update!(order: index)
          end
        end
        head :no_content
      end

      def destroy
        @task.destroy
        head :no_content
      end

      def clear
        current_user.tasks.delete_all
      end

      private

      def set_task
        @task = current_user.tasks.find(params[:id])
      end

      def set_category
        @category = current_user.categories.find_or_create_by(name: params[:category])
      end

      def task_params
        params.require(:task).permit(:id, :order, :description, :finished, :category_id)
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
