# This migration comes from surveyor_gui (originally 20140602030330)
class AddColumnIdToAnswers < ActiveRecord::Migration[4.2]
  def change
    add_column :answers, :column_id, :integer
  end
end
