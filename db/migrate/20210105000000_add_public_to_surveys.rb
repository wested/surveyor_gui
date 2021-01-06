class AddPublicToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :public, :boolean, default: false
  end
end
