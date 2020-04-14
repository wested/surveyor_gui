module SurveyorGui
  module Helpers
    module SurveyorGuiHelperMethods
      # Responses
      def response_for(response_set, question, answer = nil, response_group = nil, column_id = nil)
        return nil unless response_set && question && question.id
        result = response_set.responses.detect{|r|
          (r.question_id == question.id) &&
          (answer.blank? ? true : r.answer_id == answer.id) &&
          (r.response_group.blank? ? true : r.response_group.to_i == response_group.to_i) &&
          (r.column_id.blank? ? true : r.column_id == column_id.to_i)}
        result.blank? ? response_set.responses.build(
          question_id: question.id,
          response_group: response_group,
          column_id: column_id) : result
      end

      # Scoring
      def answer_result_css_class(response, answer_option)
        if answer_option.weight && answer_option.weight > 0
          "correct"
        elsif response && response.answer_id == answer_option.id && (answer_option.weight.nil? || answer_option.weight < 0)
          "incorrect"
        end
      end
    end
  end
end
