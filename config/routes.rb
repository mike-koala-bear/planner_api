Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users
      post 'login', to: 'sessions#create'

      resources :todos do
        collection do
          delete 'clear'
          post 'generate'
          patch 'update_order'
        end
      end
    end
  end
end
