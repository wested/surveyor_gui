# This migration comes from surveyor_gui (originally 20140530181134)
class AddIsCommentToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :is_comment, :boolean, default: false
  end
end
