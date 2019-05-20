class Dependency < ApplicationRecord
  include Surveyor::Models::DependencyMethods
  include SurveyorGui::Models::DependencyMethods
end
