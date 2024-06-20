require 'json_web_token_service'

module Api
  module V1
    class PagesController < ApplicationController
      before_action :set_page, only: [:update, :show, :destroy]

      def index
        @pages = current_user.pages
        render json: @pages
      end

      def create
        @page = current_user.pages.new(page_params)
        if @page.save
          render json: @page, status: :created
        else
          render json: @page.errors, status: :unprocessable_entity
        end
      end

      def update
        if @page.update(page_params)
          render json: @page
        else
          render json: @page.errors, status: :unprocessable_entity
        end
      end

      def show
        render json: @page
      end

      def destroy
        @page.destroy
        head :no_content
      end

      private

      def set_page
        @page = Page.find(params[:id])
      end

      def page_params
        params.require(:page).permit(:title, :content)
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
