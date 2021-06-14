# This migration comes from surveyor_gui (originally 20140308174532)
class AddModifiableToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :modifiable, :boolean, :default=>true
  end
end
