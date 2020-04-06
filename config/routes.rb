Rails.application.routes.draw do
  get 'home/index'

  concern :snake do
    post '/start', to: 'snake#start', as: nil
    post '/move',  to: 'snake#move',  as: nil
    post '/end',   to: 'snake#end',   as: nil
    post '/ping',  to: 'snake#ping',  as: nil
  end

  concerns :snake

  scope "/ml", default: { ml: true } do
    concerns :snake
  end

  resources :games, only: [:index, :show]
  resources :moves, only: [:show]

  root to: 'home#index'
end
