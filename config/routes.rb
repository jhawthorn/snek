Rails.application.routes.draw do
  post '/start', to: 'snake#start'
  post '/move',  to: 'snake#move'
  post '/end',   to: 'snake#end'
  post '/ping',  to: 'snake#ping'
end
