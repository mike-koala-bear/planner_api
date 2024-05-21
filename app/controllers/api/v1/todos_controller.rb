module Api
  module V1
    class TodosController < ApplicationController
      def index
        todos = Todo.all
        render json: todos
      end

      def show
        todo = Todo.find(params[:id])
        render json: todo
      end

      def create
        todo = Todo.new(todo_params)
        if todo.save
          render json: todo, status: :created
        else
          render json: todo.errors, status: :unprocessable_entity
        end
      end

      def update
        todo = Todo.find(params[:id])
        if todo.update(todo_params)
          render json: todo
        else
          render json: todo.errors, status: :unprocessable_entity
        end
      end

      def destroy
        todo = Todo.find(params[:id])
        todo.destroy
        head :no_content
      end

      def clear
        Todo.delete_all
        head :no_content
      end

      def generate
        letters = ('A'..'Z').to_a
        todos = letters.map do |letter|
          Todo.create(description: letter, finished: false)
        end
        render json: todos, status: :created
      end

      private

      def todo_params
        params.require(:todo).permit(:description, :finished)
      end
    end
  end
end
