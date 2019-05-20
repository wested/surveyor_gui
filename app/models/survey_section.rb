class SurveySection < ApplicationRecord
  include Surveyor::Models::SurveySectionMethods
  include SurveyorGui::Models::SurveySectionMethods
end
