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
        @task = current_user.tasks.new(task_params)
        @task.category = @category
          @task.due_date = nil if task_params[:due_date].blank?
          @task.until = nil if task_params[:until].blank?

        if @task.valid?
          Rails.logger.debug "Task is valid: #{@task.inspect}"
        else
          Rails.logger.error "Task is invalid: #{@task.errors.full_messages}"
        end

        if @task.save!
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
    category = Category.find_by(id: params[:category_id], user_id: current_user.id)
    return render json: { error: "Category not found" }, status: :not_found unless category

    task_order = params[:order][params[:category_id].to_s]
    task_order.each_with_index do |task, index|
      task_record = Task.find_by(id: task[:id])
      if task_record
        task_record.update!(order: index + 1)
      else
        render json: { error: "Task not found" }, status: :not_found and return
      end
    end

    render json: { message: 'Order updated successfully' }, status: :ok
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

          @category = current_user.categories.find_or_create_by!(name: category_name)
          @task.category = @category if @task
          Rails.logger.debug "Category: #{@category.inspect}"
        end
      end

      def task_params
        params.require(:task).permit(:id, :order, :description, :finished, :category_id, :due_date, :created_at, :updated_at, :user_id, :until,
        :priority)
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
