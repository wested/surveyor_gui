class AddDynamicSourceToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :dynamic_source, :string
  end
end
