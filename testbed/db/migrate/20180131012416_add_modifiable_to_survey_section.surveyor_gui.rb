# This migration comes from surveyor_gui (originally 20140308172417)
class AddModifiableToSurveySection < ActiveRecord::Migration
  def change
    add_column :survey_sections, :modifiable, :boolean, :default=>true
  end
end
