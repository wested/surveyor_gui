# This migration comes from surveyor_gui (originally 20140308175305)
class AddDynamicallyGenerateToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :dynamically_generate, :boolean, :default=>false
  end
end
