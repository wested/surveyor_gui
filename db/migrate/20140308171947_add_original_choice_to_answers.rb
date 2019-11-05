class AddOriginalChoiceToAnswers < ActiveRecord::Migration[4.2]
  def change
    add_column :answers, :original_choice, :string
  end
end
