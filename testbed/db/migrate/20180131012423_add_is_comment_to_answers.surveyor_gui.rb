# This migration comes from surveyor_gui (originally 20140531012006)
class AddIsCommentToAnswers < ActiveRecord::Migration[4.2]
  def change
    add_column :answers, :is_comment, :boolean, default: false
  end
end
