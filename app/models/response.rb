class Response < ApplicationRecord
  include Surveyor::Models::ResponseMethods
  include SurveyorGui::Models::ResponseMethods
end
