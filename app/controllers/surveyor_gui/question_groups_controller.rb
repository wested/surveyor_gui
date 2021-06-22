class SurveyorGui::QuestionGroupsController < ApplicationController
  layout 'surveyor_gui/surveyor_gui_default'

  def new
    @title = "Add Question Group"
    @survey_section_id = question_params[:survey_section_id]
    @survey_section = SurveySection.find(question_params[:survey_section_id])
    @survey = @survey_section.survey

    @question_group = QuestionGroup.new(
        text: params[:text],
        question_type_id: params[:question_type_id])
    original_question = Question.find(question_params[:question_id]) unless question_params[:question_id].blank? || question_params[:question_id].to_i < 1
    if original_question
      @question_group.questions.build(
          display_order: params[:display_order],
          id: params[:question_id],
          question_type_id: original_question.question_type_id,
          pick: original_question.pick,
          display_type: original_question.display_type)
    else
      @question_group.questions.build(
          display_order: params[:display_order])
      @question_group.questions.first.answers.build(:text => '', :response_class=>"string")
    end

    render "surveyor_gui/questions/new", locals: { question: @question_group }
  end


  def edit
    @title = "Edit Question Group"
    @question_group = QuestionGroup.includes(:questions).find(params[:id])
    @question_group.question_type_id = params[:question_type_id]
    @survey_section_id = params[:survey_section_id]
    @survey_section = SurveySection.find(params[:survey_section_id])
    @survey = @survey_section.survey

    render "surveyor_gui/questions/new", locals: { question: @question_group }
  end

  def create
    Question.transaction do

      # This is a hack to allow non-group questions to be edited and converted to group questions....
      # Need to convert to int because the UI is passing in an undefined :(
      if params[:converted_question_id].to_i.present? && params[:converted_question_id].to_i > 0
        Question.find(params[:converted_question_id]).destroy
      end

      insert_question_after = Question.find(params[:prev_question_id])&.display_order||1 if params[:prev_question_id].present?

      @question_group = QuestionGroup.new(question_group_params)
      @survey_section = SurveySection.find(question_group_params[:survey_section_id])
      @survey = @survey_section.survey
      @survey_section_id = question_group_params[:survey_section_id]

      if insert_question_after
        insert_question_after += 1

        @question_group.questions.to_a.each_with_index do |question, i|
          question.display_order = insert_question_after + i
        end
      end

      if @question_group.save
        #@question_group.questions.update(survey_section_id: question_group_params[])
        original_question = Question.find(question_group_params[:question_id]) if !question_group_params[:question_id].blank?
        original_question.destroy if original_question

        redirect_to surveyor_gui.edit_surveyform_url(@survey_section.survey)
      else
        @title = "Add Question Group"
        render "surveyor_gui/questions/new", locals: { question: @question_group }
      end
    end

  end

  def update
    @title = "Update Question Group"
    @question_group = QuestionGroup.includes(:questions).find(params[:id])
    @survey_section = @question_group.questions.first.survey_section

    if @question_group.update(question_group_params)

      redirect_to surveyor_gui.edit_surveyform_url(@survey_section.survey)

      #If a nested question is destroyed, the Question model performs a cascade delete
      #on the parent QuestionGroup (stuck with this behaviour as it is a Surveyor default).
      #Need to check for this and restore question group.
      begin
        QuestionGroup.find(params[:id])
      rescue
        scrubbed_params = question_group_params.to_hash
        scrubbed_params.delete("questions_attributes")
        new_question_group = QuestionGroup.create!(scrubbed_params)
        Question.where(question_group_id: @question_group.id).update_all(question_group_id: new_question_group.id)
      end
    else
      @survey_section = SurveySection.find(question_group_params[:survey_section_id])
      @survey = @survey_section.survey
      @survey_section_id = question_group_params[:survey_section_id]

      render "surveyor_gui/questions/new", locals: { question: @question_group }
    end

  rescue Exception => e
    if e.is_a? CannotDeleteException
      @survey_section = SurveySection.find(question_group_params[:survey_section_id])
      @survey = @survey_section.survey
      @survey_section_id = question_group_params[:survey_section_id]

      @question_group.errors.add(:base, e.message)

      render "surveyor_gui/questions/new", locals: { question: @question_group }
    else
      raise e
    end
  end

  def render_group_inline_partial
    if params[:id].blank?
      @question_group = QuestionGroup.new
    else
      @question_group = QuestionGroup.find(params[:id])
    end
    if params[:add_row]

      @question_group = QuestionGroup.new
      @question_group.questions.build(display_order: params[:display_order])
      render :partial => 'group_inline_field'
    else
      render :partial => 'group_inline_fields'
    end
  end
  private
  def question_group_params
    ::PermittedParams.new(params[:question_group]).question_group
  end

  def question_params

    # This is a hack to allow non-group questions to be edited and converted to group questions....
    if params[:action] == "new"
      params.permit(:survey_section_id, :id, :text, :question_id, :question_type_id, :display_order, :pick, :display_type, :prev_question_id).except(:question_id)
    else
      params.permit(:survey_section_id, :id, :text, :question_id, :question_type_id, :display_order, :pick, :display_type, :prev_question_id)
    end
  end

end