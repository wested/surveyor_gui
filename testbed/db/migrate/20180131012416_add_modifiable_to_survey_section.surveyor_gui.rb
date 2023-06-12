# This migration comes from surveyor_gui (originally 20140308172417)
class AddModifiableToSurveySection < ActiveRecord::Migration[4.2]
  def change
    add_column :survey_sections, :modifiable, :boolean, :default=>true
  end
end
