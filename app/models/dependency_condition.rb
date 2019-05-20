class DependencyCondition < ApplicationRecord
  include Surveyor::Models::DependencyConditionMethods
  include SurveyorGui::Models::DependencyConditionMethods
end
