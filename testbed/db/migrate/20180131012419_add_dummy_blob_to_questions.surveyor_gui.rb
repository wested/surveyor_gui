# This migration comes from surveyor_gui (originally 20140311032923)
class AddDummyBlobToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :dummy_blob, :string
  end
end
