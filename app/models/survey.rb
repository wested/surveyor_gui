class Survey < ApplicationRecord
  include Surveyor::Models::SurveyMethods
  include SurveyorGui::Models::SurveyMethods
end
