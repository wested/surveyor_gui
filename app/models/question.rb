class Question < ApplicationRecord
  include Surveyor::Models::QuestionMethods
  include SurveyorGui::Models::QuestionMethods
end
