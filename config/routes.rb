Onemyday::Application.routes.draw do

  root to: 'home#index'

  resources :users do
    resources :activities, only: [:index]
  end

  get '/edit_current_user', to: "users#edit_current"
  get '/update_avatar_facebook', to: "users#update_avatar_facebook"
  get '/update_avatar_twitter', to: "users#update_avatar_twitter"
  post '/upload_user_avatar', to: 'users#upload_avatar'

  resources :stories do
    get 'comments', on: :member
    get 'likes', on: :member
  end
  post '/upload_story_photo', to: 'stories#upload_photo'
  post '/publish', to: 'stories#publish'
  get '/search_stories', to: 'stories#search'
  post '/new_like', to: 'stories#like'
  post '/unlike', to: 'stories#unlike'
  get '/explore', to: 'stories#explore'

  get '/tags', to: 'tags#index'

  resources :comments

  resources :relationships, only: [:create, :destroy]

  resources :story_photos, only: [:destroy, :update]

  match 'auth/failure', to: redirect('/')
  match 'signout', to: 'sessions#destroy', as: 'signout'

  get '/:user_id/stories/feed', to: 'user_stories#feed', as: :feed
  get '/:user_id/stories/own', to: 'user_stories#own', as: :own_stories
  get '/:user_id/stories/liked', to: 'user_stories#liked', as: :liked_stories
  get '/:user_id/stories/unfinished', to: 'user_stories#unfinished', as: :unfinished_stories

  get '/channel.html', to: 'static_pages#channel'
  get '/landing', to: 'static_pages#landing'

  post 'auth/regular', to: "sessions#create", as: :regular_sign_in
  match 'auth/:provider/callback', to: 'sessions#create'
  post 'auth/:provider/destroy', to: 'sessions#destroy_auth', as: :auth_destroy

  get '/invite_friends', to: "invite_friends#index", as: :invite_friends

  scope module: "api" do
    post '/api/stories/:id/like', to: 'stories#like'
    post '/api/stories/:id/unlike', to: 'stories#unlike'

    post '/api/comments/create', to: 'comments#create'
    post '/api/comments/:id/destroy', to: 'comments#destroy'
  end
end
