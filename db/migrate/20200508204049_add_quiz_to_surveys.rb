class AddQuizToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :quiz, :boolean, default: false
  end
end
