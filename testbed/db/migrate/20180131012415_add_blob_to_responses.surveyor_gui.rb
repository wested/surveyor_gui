# This migration comes from surveyor_gui (originally 20140308172118)
class AddBlobToResponses < ActiveRecord::Migration[4.2]
  def change
    add_column :responses, :blob, :string
  end
end
