Rails.application.routes.draw do

  #resources :image_searches
  resources :subapps
  devise_for :users
  resources :images
  resources :users
  root 'subapps#index'
  post '/image_searches/' => 'image_searches#search_and_upload_image', :as => 'search_and_upload_panel'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
