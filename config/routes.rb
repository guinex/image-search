Rails.application.routes.draw do

  resources :image_searches, only: [:index, :show,:edit,:destroy]
  resources :subapps
  devise_for :users
  resources :images
  resources :users
  root 'subapps#index'
  get '/search_and_upload_image' => 'image_searches#search_and_upload_image', :as => 'image_search_app'
  post '/search_and_upload_image' => 'image_searches#search_and_upload_image', :as => 'search_and_upload_panel'
  get 'api/get_similar_designs' => 'api#get_similar_designs'
  post '/search_and_upload_image/add_similar_design' => 'image_searches#add_similar_design', as: 'add_similar'
  post '/search_and_upload_image/remove_similar_design' => 'image_searches#remove_similar_design', as: 'remove_similar'
  post '/search_and_upload_image/re_check_similar' => 'image_searches#re_check_similar', as: 'recheck_similar'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
