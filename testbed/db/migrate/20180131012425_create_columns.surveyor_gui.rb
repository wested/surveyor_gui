# This migration comes from surveyor_gui (originally 20140601011151)
class CreateColumns < ActiveRecord::Migration
  def change
    create_table :columns do |t|
      t.integer :question_group_id
      t.text :text
      t.text :answers_textbox

      t.timestamps
    end
  end
end
