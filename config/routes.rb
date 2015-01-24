Rails.application.routes.draw do  

root 'users#home'


#temporary

get 'u_home' => 'users#home'
get 'u_login' => 'users#login'
get 'u_logout' => 'users#logout'
get 'u_index' => 'users#index'
get 'u_show' => 'users#show'
get 'u_req' => 'users#requests_list'
get 'u_contact' => 'users#contact'

get 'f_new' => 'files#new'
get 'f_show' => 'files#show'

get 'vauthentication' => 'users#vauthentication'
get 'authentication' => 'users#authentication'

get 'index' => 'users#index'
get 'show' => 'users#show'
get 'requests' => 'users#requests_list’


post 'file/fetch', :to => 'files#fetch', :as => 'fetch_file'
post 'file/update', :to => 'files#update', :as => 'update_file'
get 'file/compile', :to => 'files#compile', :as => 'compile_file'
get 'file/fetch_videos', :to => 'files#fetch_videos', :as => 'fetch_videos_file'
get 'file/fetch_video', :to => 'files#fetch_video', :as => 'fetch_video_file'


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
