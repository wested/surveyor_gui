class SurveyorGui::QuestionsController < ApplicationController
  # layout 'surveyor_gui/surveyor_gui_blank'

  layout 'surveyor_gui/surveyor_gui_default'

  def new
    @title = "Add Question"
    @survey_section = SurveySection.find(params[:survey_section_id])
    @survey = Survey.find(@survey_section.survey_id)
    @question_group = QuestionGroup.new
    if params[:prev_question_id]
      prev_question_display_order = _get_prev_display_order(params[:prev_question_id])
      @question = Question.new(:survey_section_id => params[:survey_section_id],
                               :text => params[:text],
                               :display_type => "default",
                               :display_order => prev_question_display_order)
    else
      @question = Question.new(:survey_section_id => params[:survey_section_id],
                               :text => params[:text],
                               :display_type => "default",
                               :display_order => params[:display_order] || 0)
    end
    @question.question_type_id = params[:question_type_id] if !params[:question_type_id].blank?
    @question.answers.build(:text => '', :response_class=>"string")

    render "new", locals: { question: @question }
  end

  def edit
    @title = "Edit Question"
    @question = Question.includes(:answers).find(params[:id])
    @survey_section = @question.survey_section
    @survey = @survey_section.survey

    @question.question_type_id = params[:question_type_id] if !params[:question_type_id].blank?

    render "new", locals: { question: @question }
  end

  def create

    Question.transaction do
      if !params[:question][:answers_attributes].blank? && !params[:question][:answers_attributes]['0'].blank?
        params[:question][:answers_attributes]['0'][:original_choice] = params[:question][:answers_attributes]['0'][:text]
      end
      @question = Question.new(question_params)

      if params[:prev_question_id].present?
        previous_question = Question.find(params[:prev_question_id])
      end

      @question.display_order = previous_question&.next_display_order||1

      if @question.save
        @question.answers.each_with_index {|a, index| a.destroy if index > 0} if @question.pick == 'none'
        #load any page - if it has no flash errors, the colorbox that contains it will be closed immediately after the page loads
        # render :inline => '<div id="cboxQuestionId">'+@question.id.to_s+'</div>', :layout => 'surveyor_gui/surveyor_gui_blank'

        redirect_to surveyor_gui.edit_surveyform_url(@question.survey_section.survey)

      else
        @title = "Add Question"
        @survey_section = @question.survey_section
        @survey = Survey.find(@survey_section.survey_id)

        handle_errors

        render "new", locals: { question: @question }
      end
    end

  end

  def update
    @title = "Update Question"
    @question = Question.includes(:answers).find(question_params[:id])
    if @question.update(question_params)
      @question.answers.each_with_index {|a, index| a.destroy if index > 0} if @question.pick == 'none'

      #load any page - if it has no flash errors, the colorbox that contains it will be closed immediately after the page loads
      redirect_to surveyor_gui.edit_surveyform_url(@question.survey_section.survey)
    else
      @survey_section = @question.survey_section
      @survey = Survey.find(@survey_section.survey_id)

      handle_errors
      render "new", locals: { question: @question }
    end
  end

  def destroy
    question = Question.find(params[:id])
    # if !question.survey_section.survey.template && question.survey_section.survey.response_sets.count > 0
    #   flash[:error]="Responses have already been collected for this survey, therefore it cannot be modified. Please create a new survey instead."
    #   return false
    # end
    if question.dependent_questions.any?
      render :plain=> dependent_delete_failure_message(question)
      return
    end
    if question.part_of_group?
      question.question_group.questions.each{|q| q.destroy}
      render :plain=>''
      return
    end
    question.destroy
    render :plain=>''
  end


  def render_answer_fields_partial
    if params[:id].blank?
      @questions = Question.new
    else
      @questions = Question.find(params[:id])
    end
    if @questions.answers.empty?
      @questions.answers.build(:text=>'')
    else
      if !@questions.answers.first.original_choice.blank?
        @questions.answers.first.update_attribute(:text,@questions.answers.first.original_choice)
      end
      if params[:add_row]
        display_order = @questions.answers.maximum(:display_order)
        display_order = display_order ? display_order + 1 : 0
        @questions = Question.new
        @questions.answers.build(:text=>'', :display_order=>display_order)
      end
    end
    render :partial => 'answer_form'
  end

  def render_grid_partial
    if params[:id].blank?
      @questions = Question.new
    else
      @questions = Question.find(params[:id])
    end
    if @questions.answers.empty?
      @questions.answers.build(text: "", response_class: "answer")
    else
      if !@questions.answers.first.original_choice.blank?
        @questions.answers.first.update_attribute(:text,@questions.answers.first.original_choice)
      end
    end
    if @questions.question_group
      @question_group=@questions.question_group
    else
      @question_group=QuestionGroup.new
      @question_group.columns.build
    end
    column_count = @question_group.columns.size
    requested_columns = params[:index] == "NaN" ? column_count : params[:index].to_i
    if requested_columns >= column_count
      requested_columns = requested_columns - column_count
      (requested_columns).times.each {@question_group.columns.build}
    else
      @question_group.trim_columns (column_count-requested_columns)
    end
    @questions.dropdown_column_count = requested_columns.to_i+1
    if params[:question_type_id] == "grid_dropdown"
      render :partial => 'grid_dropdown_fields'
    else
      render :partial => 'grid_fields'
    end
  end


  def render_no_picks_partial
    if params[:id].blank?
      @questions = Question.new
    else
      @questions = Question.find(params[:id])
    end
    if @questions.answers.empty?
      @questions.answers.build(:text=>'')
    end
    render :partial => 'no_picks'
  end

  private
  def question_params
    ::PermittedParams.new(params[:question]).question
  end

  def handle_errors
    if @question.part_of_group?
      @question.errors.clear
      @question.errors.add(:base, "Please be sure you have filled in all required fields.")
    end
  end

  def _get_prev_display_order(prev_question)
    prev_question = Question.find(prev_question)
    if prev_question.part_of_group?
      prev_question.question_group.questions.last.display_order + 1
    else
      prev_question.display_order + 1
    end
  end

  def dependent_delete_failure_message(question)

    questions = question.dependent_questions.map do |d|
      question = d.dependency.question||d.dependency.question_group
      " - #{ActionController::Base.helpers.strip_tags(question.text)}"
    end.join('\n')

    "The following questions have logic that depend on this question: \n\n"+ questions +"\n\nPlease delete logic before deleting this question.".html_safe
  end
end