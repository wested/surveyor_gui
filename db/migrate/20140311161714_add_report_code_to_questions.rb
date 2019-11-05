class AddReportCodeToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :report_code, :string
  end
end
