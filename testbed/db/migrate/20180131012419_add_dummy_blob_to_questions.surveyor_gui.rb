# This migration comes from surveyor_gui (originally 20140311032923)
class AddDummyBlobToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :dummy_blob, :string
  end
end
