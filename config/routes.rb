Rails.application.routes.draw do

  resources :subapps
  devise_for :users
  resources :images
  resources :users
  root 'subapps#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
