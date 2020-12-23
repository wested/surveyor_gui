SurveyorGui::Engine.routes.draw do

  resources :surveyforms do
    member do
      get 'replace_form'
      get 'insert_survey_section'
      get 'replace_survey_section'
      get 'insert_new_question'
      get 'replace_question'
      get 'clone_survey'
      put 'create_cloned'
      patch 'create_cloned'
      get 'set_default'
      get 'cut_section'
      get 'paste_section'
      post 'reorder_questions'
    end
  end

  resources :survey_sections do
    post :sort, :on => :collection
  end

  resources :questions do
    member do
      get 'cut'
    end
    collection do
      get 'render_answer_fields_partial'
      get 'render_grid_partial'
      get 'render_no_picks_partial'
    end
  end

  resources :question_groups do
    collection do
      get 'render_group_inline_partial'
    end
  end

  resources :dependencys do
    collection do
      get 'get_answers'
      get 'get_question_type'
      get 'get_columns'
    end
  end
  get '/dependency/render_dependency_conditions_partial', :to => 'dependencys#render_dependency_conditions_partial'

  resources :scores

  resources :reports,
            :only=>[
                'show',
                'preview',
                'show_pdf'] do
    member do
      get 'show'
      get 'preview'
      get 'show_pdf'
    end
  end
  resources :survey, only: ['show'] do
  end
  resources :responses, only: ['show', 'index', 'preview', 'destroy_all'] do
    member do
      get 'preview'
    end

    collection do
      delete 'destroy_all'
    end
  end
end