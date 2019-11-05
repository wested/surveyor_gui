class AddTestDataToResponseSets < ActiveRecord::Migration[4.2]
  def change
    add_column :response_sets, :test_data, :boolean, :default=>false
  end
end
