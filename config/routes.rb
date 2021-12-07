Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      get 'notes/:id/shared_notes', to: 'notes#getAllSharedNotesByNote'
      resources :notes
      get 'shared_notes/copy/:uuid', to: 'shared_notes#copy'
      resources :shared_notes, only: [:show, :create, :destroy]
      resources :test, only: [:index]
    end
  end
end
