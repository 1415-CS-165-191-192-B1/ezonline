Rails.application.routes.draw do  

root 'user#home'


#temporary
get 'user/home' => 'user#home'
get 'user/login' => 'user#login'
get 'user/logout' => 'user#logout'
get 'user/index' => 'user#index'
get 'user/show' => 'user#show'
get 'user/req' => 'user#requests_list'
get 'user/contact' => 'user#contact'

get 'file/new' => 'file#new'
get 'file/show' => 'file#show'

get 'file/refresh_videos' => 'file#refresh_videos'

get 'vauthentication' => 'user#vauthentication'
get 'authentication' => 'user#authentication'

get 'index' => 'user#index'
#get 'show' => 'user#show'
#get 'requests' => 'user#requests_list'

get 'vlogin/user' => 'user#vlogin'
post 'fetch/file' => 'file#fetch'
post 'file/update' => 'file#update'


  resources :file do
    collection do
      get 'show'
      post 'save_task'
    end
    member do
      get 'history'
      get 'compile'
      get 'delete'
      get 'fetch_video'
      get 'fetch_videos'
      get 'edit'
      get 'assign'
    end
  end

  resources :user do
    collection do
      get 'login'
      get 'logout'
      get 'requests_list'
      get 'show'
      get 'admin_index'
      post 'delete_notifs'
    end
    member do 
      get 'unauthorize'
      get 'notify'
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
