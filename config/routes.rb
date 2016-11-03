Rails.application.routes.draw do

  resources :manage_catalogs, only: [:index]
  resources :image_searches, only: [:index, :show,:edit,:destroy]
  resources :subapps
  devise_for :users
  resources :images
  resources :users
  root 'subapps#index'
  get '/search' => 'image_searches#search_and_upload_image', :as => 'image_search_app'
  post '/search' => 'image_searches#search_and_upload_image', :as => 'search_and_upload_panel'
  get 'api/get_similar_designs' => 'api#get_similar_designs'
  post '/search/add_similar_design' => 'image_searches#add_similar_design', as: 'add_similar'
  post '/search/remove_similar_design' => 'image_searches#remove_similar_design', as: 'remove_similar'
  post '/search/check_similar' => 'image_searches#re_check_similar', as: 'recheck_similar'
  get '/manage-catalogs/all' => 'manage_catalogs#remove_designs_from_catalog', as:"all_catalog"
  post '/manage-catalogs/all' => 'manage_catalogs#remove_designs_from_catalog', as:"remove_catalog"
  get 'api/international_catalog_designs' => 'api#international_catalog_designs'
  post 'api/international_catalog_response' => 'api#international_catalog_response'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
