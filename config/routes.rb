require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users
  mount Sidekiq::Web => '/sidekiq'


  resources :accounts, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :budgets, only: [:index, :edit, :update]
  resources :merge_accounts, only: [:new, :create]
  resources :merge_transactions, only: [:new, :create]
  resources :one_time_budgeted_amounts, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :transaction_imports, only: [:index, :new, :create, :edit, :update]
  resources :transactions
  resources :split_transactions, only: [:show, :new, :create]
  resources :unmatched_transactions, only: [:edit, :update]

  namespace :reports do
    resources :assets, only: :index
    resources :dashboards, only: :index
    resources :profit_and_losses, only: :index

    namespace :charts do
      resources :asset_balances, only: :show
      resources :cash_flows, only: :show
      resources :projected_expenses, only: :show
    end
  end

  root 'reports/dashboards#index'
end
