Rails.application.routes.draw do
  resources :accounts, only: [:index, :new, :create]

  root 'accounts#index'
end
