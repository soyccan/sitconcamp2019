Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
    resources :records, only: [:index, :new, :create]
    get 'records/:page', to: 'records#index', constraints: {page: /[0-9]+/}
    match 'countries/*props', to: 'countries#index', via: :all, constraints: {props: /[a-z\/]+/}
end
