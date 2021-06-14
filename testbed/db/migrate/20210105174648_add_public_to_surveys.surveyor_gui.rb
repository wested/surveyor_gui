# This migration comes from surveyor_gui (originally 20210105000000)
class AddPublicToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :public, :boolean, default: false
  end
end
