class QuestionScorer

  def initialize(response, answer_option, question)
    @response = response
    @answer_option = answer_option
    @question = question
  end

  def correct?
    user_answer_matches && question_correct_option
  end

  def missed?
    !user_answer_matches && question_correct_option
  end

  def incorrect?
      user_answer_matches && question_incorrect_option
  end

  private

  def user_answer_matches
    @response.answer_id == @answer_option.id
  end

  def question_correct_option
    @answer_option.weight && @answer_option.weight > 0
  end

  def question_incorrect_option
    @answer_option.weight.nil? || @answer_option.weight <= 0
  end
end