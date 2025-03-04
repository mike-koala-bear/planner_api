Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users
      post 'login', to: 'sessions#create'

      resources :tasks do
        collection do
          delete 'clear'
          post 'generate'
        end
      end

      resources :pages

      resources :categories do
        member do
          patch 'update_sorting_mode'
        end
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
