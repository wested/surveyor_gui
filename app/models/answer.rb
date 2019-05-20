class Answer < ApplicationRecord
  include Surveyor::Models::AnswerMethods
  include SurveyorGui::Models::AnswerMethods
end
