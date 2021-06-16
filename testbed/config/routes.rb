Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  mount SurveyorGui::Engine => "/surveyor_gui", :as => "surveyor_gui"
  mount Surveyor::Engine => "/surveys", :as => "surveyor"

  root :to => 'surveyor#index'
end
