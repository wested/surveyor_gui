class AddColumnIdToResponses < ActiveRecord::Migration[4.2]
  def change
    add_column :responses, :column_id, :integer
  end
end
