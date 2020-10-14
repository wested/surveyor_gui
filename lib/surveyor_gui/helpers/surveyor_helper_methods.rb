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

      def responses_for(response_set, question)
        return nil unless response_set && question && question.id

        result = response_set.responses.find_all{ |r| r.question_id == question.id }

        result.blank? ? [] : result
      end

      # Scoring
      def answer_result_css_class(response, answer_option, question_type)
        if response
          if question_type == "any"

            if user_answer_matches(response, answer_option) && question_incorrect_option(answer_option)
              response.incorrect = true
              "incorrect"
            elsif !user_answer_matches(response, answer_option) && question_correct_option(answer_option)
              response.incorrect = true
              "missed"
            elsif user_answer_matches(response, answer_option) && question_correct_option(answer_option)
              "correct"
            end

          else

            if question_correct_option(answer_option)
              "correct"
            elsif user_answer_matches(response, answer_option) && question_incorrect_option(answer_option)
              response.incorrect = true
              "incorrect"
            end

          end
        end
      end

      private

      def user_answer_matches(response, answer_option)
        response.answer_id == answer_option.id
      end

      def question_correct_option(answer_option)
        answer_option.weight && answer_option.weight > 0
      end

      def question_incorrect_option(answer_option)
        answer_option.weight.nil? || answer_option.weight <= 0
      end
    end
  end
end
