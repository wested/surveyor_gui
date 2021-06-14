# This migration comes from surveyor_gui (originally 20140603155606)
class AddColumnIdToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :column_id, :integer
  end
end
