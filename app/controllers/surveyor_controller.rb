module SurveyorControllerCustomMethods
  def self.included(base)
    base.send :layout, 'surveyor_gui/surveyor_modified'
  end

  def edit
    root = File.expand_path('../../', __FILE__)
    #place the surveyor_gui views ahead of the default surveyor view in order of preference
    #so we can load customized partials.
    prepend_view_path(root+'/views')
    super
  end

end
class SurveyorController < ApplicationController
  include Surveyor::SurveyorControllerMethods
  include SurveyorControllerCustomMethods
end
