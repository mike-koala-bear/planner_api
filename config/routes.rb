Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users
      post 'login', to: 'sessions#create'

      resources :tasks do
        collection do
          delete 'clear'
          post 'generate'
          patch 'update_order'
        end
      end
      resources :categories, only: [:index, :create, :destroy]
    end
  end
end
