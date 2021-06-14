# This migration comes from surveyor_gui (originally 20140307235607)
class AddTestDataToResponseSets < ActiveRecord::Migration
  def change
    add_column :response_sets, :test_data, :boolean, :default=>false
  end
end
