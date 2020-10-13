class AddCorrectAndIncorrectFeedbackToAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :correct_feedback, :text
    add_column :questions, :incorrect_feedback, :text
  end
end
