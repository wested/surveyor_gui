# This migration comes from surveyor_gui (originally 20201012204049)
class AddCorrectAndIncorrectFeedbackToAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :correct_feedback, :text
    add_column :questions, :incorrect_feedback, :text
  end
end
