Rails.application.routes.draw do
  root 'application#root'

  get 'lyrics/:artist/:title', to: 'application#lyrics'
  get 'tracks', to: 'application#tracks'
end
