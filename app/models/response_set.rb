class ResponseSet < ApplicationRecord
  include Surveyor::Models::ResponseSetMethods
  include SurveyorGui::Models::ResponseSetMethods
end
