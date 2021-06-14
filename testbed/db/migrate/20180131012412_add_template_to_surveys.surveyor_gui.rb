# This migration comes from surveyor_gui (originally 20140307204049)
class AddTemplateToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :template, :boolean, :default => false
  end
end
