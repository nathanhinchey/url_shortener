Rails.application.routes.draw do
  scope 'api' do
    scope 'v1' do
      post 'user_token' => 'user_token#create'

      resources :links

      resources :users, only: :create
    end
  end

  # redirecting
  get '/:slug', to: 'links#slug_redirect'
end
