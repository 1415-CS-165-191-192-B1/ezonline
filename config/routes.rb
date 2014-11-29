Rails.application.routes.draw do  

root 'user#home'

get 'u_login' => 'user#login'
get 'u_logout' => 'user#logout'



get 'user/vlogin' => 'user#vlogin'

get 'vauthentication' => 'user#vauthentication'
get 'authentication' => 'user#authentication'

post 'user/show' => 'user#show'
post 'file/new' => 'file#new'
post 'file/fetch' => 'file#fetch'
post 'file/update' => 'file#update'

get 'index' => 'user#index'
get 'show' => 'user#show'
get 'requests' => 'user#requests_list'



  resources :file do
    collection do
      get 'show'
      get 'history'
    end
  end

  resources :user do
    collection do
      get 'logout'
      get 'requests_list'
      get 'show'
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
