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

      resources :categories do
        resources :tasks do
          collection do
            delete 'clear'
            post 'generate'
            patch 'update_order'
          end
        end
        patch 'update_size', to: 'categories#update_size'
      end
    end
  end
end
