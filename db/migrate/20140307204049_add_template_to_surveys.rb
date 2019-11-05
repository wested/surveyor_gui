class AddTemplateToSurveys < ActiveRecord::Migration[4.2]
  def change
    add_column :surveys, :template, :boolean, :default => false
  end
end
