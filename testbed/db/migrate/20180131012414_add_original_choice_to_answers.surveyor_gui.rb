# This migration comes from surveyor_gui (originally 20140308171947)
class AddOriginalChoiceToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :original_choice, :string
  end
end
