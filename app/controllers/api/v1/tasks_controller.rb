require 'json_web_token_service'

module Api
  module V1
    class TasksController < ApplicationController
      before_action :set_task, only: [:show, :update, :destroy]
      before_action :set_category, only: [:create, :update]

      def index
        if params[:category_id]
          @tasks = current_user.tasks.where(category_id: params[:category_id])
        else
          @tasks = current_user.tasks.all
        end
        render json: @tasks
      end

      def create
        @category = current_user.categories.find_or_create_by(name: params[:category])
        @task = current_user.tasks.build(task_params)
        @task.category = @category

        if @task.valid?
          Rails.logger.debug "Task is valid: #{@task.inspect}"
        else
          Rails.logger.error "Task is invalid: #{@task.errors.full_messages}"
        end

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
        Rails.logger.debug "Params received: #{params.inspect}"

        ActiveRecord::Base.transaction do
          params.require(:order).each do |container_id, tasks|
            tasks.each do |task|
              task_id = task[:id].to_i
              task_order = task[:order].to_i
              category_id = container_id.to_i

              Rails.logger.debug "Processing task ID: #{task_id}, order: #{task_order}, category ID: #{category_id}"

              task_to_update = current_user.tasks.find_by(id: task_id)
              unless task_to_update
                raise ActiveRecord::RecordNotFound, "Task with ID #{task_id} not found for the current user"
              end

              task_to_update.update!(order: task_order, category_id: category_id)
            end
          end
        end
        head :no_content
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error "Record not found: #{e.message}"
        render json: { error: e.message }, status: :not_found
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Record invalid: #{e.message}"
        render json: { error: e.message }, status: :unprocessable_entity
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
        if params[:category].present?
          category_name = params[:category][:name] if params[:category].is_a?(ActionController::Parameters)
          category_name ||= params[:category]

          @category = current_user.categories.find_or_create_by(name: category_name)
          @task.category = @category if @task
          Rails.logger.debug "Category: #{@category.inspect}"
        end
      end

      def task_params
        params.require(:task).permit(:id, :order, :description, :finished, :category_id, :due_date, :created_at, :updated_at, :user_id, :until)
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
