# This migration comes from surveyor_gui (originally 20140308172118)
class AddBlobToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :blob, :string
  end
end
