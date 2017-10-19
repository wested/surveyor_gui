class SurveyorGui::QuestionGroupsController < ApplicationController
  layout 'surveyor_gui/surveyor_gui_default'

  def new
    @title = "Add Question"
    @survey_section_id = question_params[:survey_section_id]
    @survey_section = SurveySection.find(question_params[:survey_section_id])
    @survey = @survey_section.survey

    @question_group = QuestionGroup.new(
        text: params[:text],
        question_type_id: params[:question_type_id])
    original_question = Question.find(params[:question_id]) unless params[:question_id].blank? || params[:question_id].to_i < 1
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
    end

    render "surveyor_gui/questions/new", locals: { question: @question_group }
  end


  def edit
    @title = "Edit Question Group"
    @question_group = QuestionGroup.includes(:questions).find(params[:id])
    @question_group.question_type_id = params[:question_type_id]
    @survey_section_id = question_params[:survey_section_id]
    p "edit survey sect id #{@survey_section_id}"
  end

  def create
    @question_group = QuestionGroup.new(question_group_params)
    @survey_section = SurveySection.find(question_group_params[:survey_section_id])
    @survey = @survey_section.survey
    @survey_section_id = question_group_params[:survey_section_id]

    if @question_group.save
      #@question_group.questions.update_attributes(survey_section_id: question_group_params[])
      original_question = Question.find(question_group_params[:question_id]) if !question_group_params[:question_id].blank?
      original_question.destroy if original_question

      redirect_to surveyor_gui.edit_surveyform_url(@survey_section.survey)
    else
      @title = "Add Question"
      render "surveyor_gui/questions/new", locals: { question: @question_group }
    end
  end

  def update
    @title = "Update Question"
    @question_group = QuestionGroup.includes(:questions).find(params[:id])
    if @question_group.update_attributes(question_group_params)
      render :blank, :layout => 'surveyor_gui/surveyor_gui_blank'
      #If a nested question is destroyed, the Question model performs a cascade delete
      #on the parent QuestionGroup (stuck with this behaviour as it is a Surveyor default).
      #Need to check for this and restore question group.
      begin
        QuestionGroup.find(params[:id])
      rescue
        scrubbed_params = question_group_params.to_hash
        scrubbed_params.delete("questions_attributes")
        QuestionGroup.create!(scrubbed_params)
      end
    else
      render :action => 'edit', :layout => 'surveyor_gui/surveyor_gui_blank'
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
    params.permit(:survey_section_id, :id, :text, :question_id, :question_type_id, :display_order, :pick, :display_type)
  end

end