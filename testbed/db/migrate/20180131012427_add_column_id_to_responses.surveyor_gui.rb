# This migration comes from surveyor_gui (originally 20140603155606)
class AddColumnIdToResponses < ActiveRecord::Migration[4.2]
  def change
    add_column :responses, :column_id, :integer
  end
end
