# This migration comes from surveyor_gui (originally 20140531225529)
class CreateRows < ActiveRecord::Migration[4.2]
  def change
    create_table :rows do |t|
      t.integer :question_group_id
      t.string :text
      t.timestamps
    end
  end
end
