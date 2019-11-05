class AddUserIdToSurvey < ActiveRecord::Migration[4.2]
  def change
    add_column :surveys, :user_id, :integer
  end
end
