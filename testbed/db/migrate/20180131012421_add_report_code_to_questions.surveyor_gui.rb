# This migration comes from surveyor_gui (originally 20140311161714)
class AddReportCodeToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :report_code, :string
  end
end
