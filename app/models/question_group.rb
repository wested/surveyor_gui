class QuestionGroup < ApplicationRecord
  include Surveyor::Models::QuestionGroupMethods
  include SurveyorGui::Models::QuestionGroupMethods
end
