module SurveyorGui::Helpers::SurveyorHelperMethods
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
  def answer_result_css_class(response, answer_option, question)
    question_scorer = QuestionScorer.new(response, answer_option, question)

    if response

      if question_scorer.incorrect?
        response.incorrect = true
        "incorrect"
      elsif question_scorer.missed?
        response.incorrect = true
        "missed"
      elsif question_scorer.correct?
        "correct"
      end

    end
  end
end
