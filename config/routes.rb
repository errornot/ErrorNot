ErrorNot::Application.routes.draw do
  resources :projects do

    member do
      put :add_member
      delete :remove_member
      get :leave
      delete :leave
      put :admins
      delete :admin
      put :reset_apikey
    end # member
    
    resources :errors, :except => [:new, :create, :update] do

      member do
        post :comment
        get :backtrace
        get :session_info
        get :data
        get :similar_error
        get :request_info
      end # member
      
      resources :same_errors, :only => [:show] do

        member do
          get :backtrace
          get :session_info
          get :data
          get :similar_error
          get :request_info
        end # member

      end # resources :same_errors

    end # resources :errors

  end # resources :projects

  resources :errors, :only => [:create, :update]

  devise_for :users
  
  resource :user do
    put :update_notify, :on => :collection
  end # resource :user
  
  root :to => "projects#index"
end # ErrorNot::Application.routes.draw