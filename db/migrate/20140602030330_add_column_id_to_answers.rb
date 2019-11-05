class AddColumnIdToAnswers < ActiveRecord::Migration[4.2]
  def change
    add_column :answers, :column_id, :integer
  end
end
