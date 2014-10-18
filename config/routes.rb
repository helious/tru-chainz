Rails.application.routes.draw do
  root 'application#root'

  get 'lyrics/:artist/:track', to: 'application#lyrics'
  get 'track/:artist/:track', to: 'application#track'
end
