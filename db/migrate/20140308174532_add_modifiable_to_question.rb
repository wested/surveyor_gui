class AddModifiableToQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :modifiable, :boolean, :default=>true
  end
end
