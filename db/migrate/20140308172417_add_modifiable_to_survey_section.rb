class AddModifiableToSurveySection < ActiveRecord::Migration[4.2]
  def change
    add_column :survey_sections, :modifiable, :boolean, :default=>true
  end
end
