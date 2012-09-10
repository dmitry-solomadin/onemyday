Onemyday::Application.routes.draw do

  resources :users
  get '/edit_current_user', to: "users#edit_current"
  get '/update_avatar_facebook', to: "users#update_avatar_facebook"
  get '/update_avatar_twitter', to: "users#update_avatar_twitter"
  post '/upload_user_avatar', to:'users#upload_avatar'

  resources :stories
  post '/upload_story_photo', to:'stories#upload_photo'
  post '/publish', to:'stories#publish'
  get '/search_stories', to: 'stories#search'
  post '/new_like', to:'stories#like'
  post '/unlike', to:'stories#unlike'

  resources :comments

  match 'auth/:provider/callback', to: 'sessions#create'
  match 'auth/:provider/destroy', to: 'sessions#destroy_auth'
  match 'auth/failure', to: redirect('/')
  match 'signout', to: 'sessions#destroy', as: 'signout'

  get '/moreinfo', to: 'add_more_user_info#show'
  put '/moreinfo', to: 'add_more_user_info#submit'

  get '/:user_id/stories/own', to: 'user_stories#own', as: :own_stories
  get '/:user_id/stories/liked', to: 'user_stories#liked', as: :liked_stories
  get '/:user_id/stories/unfinished', to: 'user_stories#unfinished', as: :unfinished_stories

  root :to => 'home#index'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
