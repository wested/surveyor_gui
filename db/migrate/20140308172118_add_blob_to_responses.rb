class AddBlobToResponses < ActiveRecord::Migration[4.2]
  def change
    add_column :responses, :blob, :string
  end
end
