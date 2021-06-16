module SurveyorGui
  module SurveyformsControllerMethods

    def self.included(base)
      base.send :layout, 'surveyor_gui/surveyor_gui_default'
    end

    def index
      context = Surveyform
      label = "All Surveys"

      if params[:template]=='false'
        context = context.where('template = ?', false)
        label = "Surveys Only"
      elsif params[:template]=='true'
        context = context.where('template = ?', true)
        label = "Templates Only"
      end
      @title = "Manage " + label
      @surveyforms = context.search(params[:search]).order(:title).paginate(:page => params[:page]).all.to_a
    end

    def new
      @title = "Create New "+ (params[:template] == 'template'? 'Template' : 'Survey')
      @hide_survey_type = params[:hide_survey_type]
      template = params[:template] == 'template'? true : false
      @surveyform = Surveyform.new(:template=>template)
      @surveyform.survey_sections.build(:title=>'Section 1', :display_order=>0, :modifiable=>true)#.questions.build(:text=>'New question',:pick=>'none',:display_order=>0,:display_type=>'default', :modifiable=>modifiable).answers.build(:text=>'string', :response_class=>'string', :display_order=>1, :template=>true)
      @question_no = 0
    end

    def edit
      @surveyform = Surveyform.where(:id=>params[:id]).includes(:survey_sections).first
      @survey_locked=false
      #unfortunately, request.referrer does not seem to capture parameters. Need to add explicitly.
      #don't edit the format of a non template survey that has responses. could cause unpredictable results
      @surveyform.response_sets.where('test_data=?',true).map{|r| r.destroy}
      if !@surveyform.template && @surveyform.responses.count>0
        # @survey_locked=true
        flash.now[:error] = "STOP!! Responses have already been collected for this survey, therefore modifications to anything other than simple text may result in data corruption.  PROCEED WITH CAUTION!!"
      end
      @title = "Edit "+ (@surveyform.template ? 'Template' : 'Survey')
      @surveyform.survey_sections.build if @surveyform.survey_sections.blank?
      @question_no = 0
      @url = "update"
    end

    def create
      @surveyform = Surveyform.new(surveyforms_params.merge(user_id: @current_user.nil? ? @current_user : @current_user.id))
      if @surveyform.save
        flash[:notice] = "Successfully created survey."
        @title = "Edit Survey"
        @question_no = 0
        redirect_to edit_surveyform_path(@surveyform.id)
      else
        render :action => 'new'
      end
    end

    def update
      @title = "Update Survey"
      @surveyform = Surveyform.includes(:survey_sections).find(params[:surveyform][:id])
      if @surveyform.update(surveyforms_params)
        flash[:notice] = "Successfully updated surveyform."
        redirect_to edit_surveyform_path(@surveyform.id)
      else
        flash[:error] = "Changes not saved."
        @question_no = 0
        render :action => 'edit'
      end
    end

    def show
      @title = "Show Survey"
      @survey_locked = true
      @surveyform = Surveyform.find(params[:id])
      @question_no = 0
    end

    def destroy
      @surveyform = Surveyform.find(params[:id])

      if @surveyform.response_sets.count > 0
        flash[:error] = 'This survey has responses and can not be deleted'
      else
        @surveyform.destroy

        if @surveyform.destroyed?
          flash[:notice] = "Successfully deleted survey."
        else
          flash[:error] = 'Survey could not be deleted.'
        end
      end

      redirect_to surveyforms_url
    end

    def replace_form
      @surveyform = SurveySection.find(params[:survey_section_id]).surveyform
      @question_no = 0
      render :new, :layout => false
    end

    def insert_survey_section
      survey_id = params[:id]
      @survey_section = Survey.find(survey_id).survey_sections.reorder('survey_sections.id').last
      if @survey_section
        @question_no = 0
        render "_survey_section_fields" , :layout=> false
      else
        render :nothing=> true
      end
    end

    def replace_survey_section
      survey_section_id = params[:survey_section_id]
      @survey_section = SurveySection.find(survey_section_id)
      @question_no = 0
      render "_survey_section_fields" , :layout=> false
    end

    def insert_new_question
      question_id = params[:question_id]
      @question = Question.find(question_id)
      @question_no = 0
      @surveyform = @question.survey_section.surveyform
      render :new, :layout=>false
    end

    def cut_section
      session[:cut_section]=params[:survey_section_id]
      if ss=SurveySection.find(params[:survey_section_id])
        @surveyform=ss.surveyform
        ss.update_attribute(:survey_id,nil)
        @question_no = 0
        render :new, :layout=>false
        return true
      end
      render :nothing=>true
      return false
    end

    def paste_section
      @title="Edit Survey"
      @question_no = 0
      if session[:cut_section]
        _continue_paste_section
      else
        render :nothing=>true
      end
    end

    def _continue_paste_section
      survey_section = SurveySection.find(session[:cut_section])
      place_at_section = SurveySection.find(params[:survey_section_id])
      survey_section.survey_id = place_at_section.survey_id
      survey_section.display_order = _paste_to(params[:position], place_at_section.survey, place_at_section)
      @surveyform = place_at_section.surveyform
      _save_pasted_object(survey_section, @surveyform, :cut_section)
    end

    def _paste_to(position, object_parent, object)
      paste_position = object.display_order + _display_order_offset(position)
      _make_room(paste_position, object_parent, object)
      paste_position
    end

    def _display_order_offset(position)
      position == "over" ? 0 : 1
    end

    def _make_room(paste_at, object_parent, object)
      statement = "object_parent."+object.class.to_s.underscore.pluralize
      collection = eval(statement)
      collection.where('display_order >= ?',paste_at).update_all('display_order=display_order+1')
    end

    def _save_pasted_object(object, surveyform, session_id)
      if object.save
        surveyform.reload
        session[session_id]=nil
        render :new, :layout=>false
      else
        render :nothing=>true
        return false
      end
    end

    def reorder_questions
      question_ids = params[:questions].split(",")
      survey_section_id = params[:survey_section_id]

      question_ids.each_with_index do | question_id, i |
        question = Question.find(question_id)
        question.update_column(:display_order, i+1)
        question.update_column(:survey_section_id, survey_section_id) if question.survey_section_id != survey_section_id

      end

      if params[:paste_question]
        @surveyform = Surveyform.find(params[:id])
        @surveyform.reload
        @question_no = 0
        render "surveyor_gui/surveyforms/new", :layout=>false
      else
        head :ok
      end

    end

    def replace_question
      question_id = params[:question_id]
      begin
        @question = Question.find(question_id)
        @question_no = 0
        render "_question_section" , :layout=> false
      rescue
        render inline: "not found"
      end
    end

    def clone_survey
      @title = "Clone Survey"
      @surveyform = SurveyCloneFactory.new(params[:id], true).clone
      if @surveyform.save
        flash[:notice] = "Successfully created survey, questionnaire, or form."
        redirect_to edit_surveyform_path(@surveyform)
      else
        flash[:error] = "Could not clone the survey, questionnaire, or form."
        render :action => 'new'
      end
    end

    private
    def surveyforms_params
      return {} unless params[:surveyform].present?

      PermittedParams.new(params[:surveyform]).survey
    end

  end
end