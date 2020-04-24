class AddInternalTitleToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :internal_title, :string
  end
end
