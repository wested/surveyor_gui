class AddDummyBlobToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :dummy_blob, :string
  end
end
