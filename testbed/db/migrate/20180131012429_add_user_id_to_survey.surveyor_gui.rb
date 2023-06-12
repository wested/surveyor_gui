# This migration comes from surveyor_gui (originally 20140815165307)
class AddUserIdToSurvey < ActiveRecord::Migration[4.2]
  def change
    add_column :surveys, :user_id, :integer
  end
end
