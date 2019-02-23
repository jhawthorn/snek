Rails.application.routes.draw do
  get 'home/index'
  post '/start', to: 'snake#start'
  post '/move',  to: 'snake#move'
  post '/end',   to: 'snake#end'
  post '/ping',  to: 'snake#ping'

  root to: 'home#index'
end
