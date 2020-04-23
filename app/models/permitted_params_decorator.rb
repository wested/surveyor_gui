PermittedParams.class_eval do
  def column
    strong_parameters.permit(*column_attributes)
  end
  def column_attributes
    [:id, :text, :question_group_id, :answers_textbox]
  end
end

module ParamDecorator
  def survey_attributes
    super +
        [:title, :access_code, :template, :id, :user_id, :internal_title,
         survey_sections_attributes: survey_section_attributes]
  end

  def survey_section_attributes
    super +
        [:title, :display_order, :questions_attributes, :survey_id, :modifiable,
         :id, questions_attributes: question_attributes]
  end

  def question_group_attributes
    super +
        [:id, :question_type, :question_type_id, :question_id, :survey_section_id, :is_mandatory,
         columns_attributes: column_attributes,
         dependency_attributes: dependency_attributes,questions_attributes: question_attributes]
  end

  def response_set_attributes
    super +
        [:survey, :responses_attributes, :user_id, :survey_id, :test_data]
  end

  def response_attributes
    super +
        [:response_set, :question, :answer, :date_value, :time_value,
         :response_set_id, :question_id, :answer_id, :datetime_value,
         :integer_value, :float_value, :unit, :text_value, :string_value,
         :response_other, :response_group, :survey_section_id, :blob, :comment]
  end

  def dependency_condition_attributes
    super +
        [:id, :_destroy, :dependency_id, :rule_key, :question_id, :operator, :answer_id,
         :float_value, :integer_value, :join_operator, :column_id, column_attributes: column_attributes]
  end

  def dependency_attributes
    super + [:id, dependency_conditions_attributes: dependency_condition_attributes]
  end

  def question_attributes
    super +
        [:question_type, :question_type_id, :survey_section_id, :question_group_id, :text,
         :text_adjusted_for_group,
         :pick, :reference_identifier, :display_order, :display_type, :is_mandatory,
         :prefix, :suffix, :decimals, :dependency_attributes, :id,
         :hide_label, :dummy_blob, :dynamically_generate, :dynamic_source,
         :omit_text, :omit, :other, :other_text, :is_comment, :comments, :comments_text,
         :modifiable, :report_code, :answers_textbox, :grid_columns_textbox, :_destroy,
         :grid_rows_textbox, :dropdown_column_count, :dummy_answer, dummy_answer_array: [], question_group_attributes: [:id, :display_type, :data_export_identifier, columns_attributes: column_attributes, questions_attributes: [:id, :pick, :display_order, :display_type, :text, :question_type_id, :_destroy]],
         answers_attributes: answer_attributes,
         dependency_attributes: dependency_attributes]
  end

  def answer_attributes
    super +
        [:text, :response_class, :display_order, :original_choice, :hide_label,
         :question_id, :display_type, :_destroy, :id, :is_comment, :comment]
  end

end
PermittedParams.prepend(ParamDecorator)
