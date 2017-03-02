Rails.application.routes.draw do
  resources :notes do
    resources :tags, only: [:create, :destroy]
  end
end
