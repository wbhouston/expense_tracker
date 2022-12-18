require 'sidekiq/web'

Rails.application.routes.draw do
  resources :accounts, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :merge_accounts, only: [:new, :create]
  resources :transaction_imports, only: [:index, :new, :create, :edit, :update]
  resources :transactions, only: [:index]

  namespace :reports do
    resources :profit_and_losses, only: :index
  end

  root 'accounts#index'
end
