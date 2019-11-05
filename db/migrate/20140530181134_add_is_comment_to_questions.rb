class AddIsCommentToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :is_comment, :boolean, default: false
  end
end
