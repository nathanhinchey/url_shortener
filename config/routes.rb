Rails.application.routes.draw do
  scope 'v1' do
    post 'user_token' => 'user_token#create'
    # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  end
end
