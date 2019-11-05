class AddColumnIdToDependencyConditions < ActiveRecord::Migration[4.2]
  def change
    add_column :dependency_conditions, :column_id, :integer
  end
end
