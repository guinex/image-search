Rails.application.routes.draw do

  resources :subapps
  devise_for :users
  #resources :images
  resources :users
  root 'subapps#index'
  post 'images/' => 'images#search_and_upload_image', :as => 'search_and_upload_panel'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
