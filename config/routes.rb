Rails.application.routes.draw do
  resources :accounts, only: [:index, :new, :create, :edit, :update, :destroy]

  root 'accounts#index'
end
