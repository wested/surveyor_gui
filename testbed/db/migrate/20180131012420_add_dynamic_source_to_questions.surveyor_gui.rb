# This migration comes from surveyor_gui (originally 20140311160609)
class AddDynamicSourceToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :dynamic_source, :string
  end
end
