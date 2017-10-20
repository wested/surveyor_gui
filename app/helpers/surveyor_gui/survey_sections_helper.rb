module SurveyorGui::SurveySectionsHelper

  def section_form_target_url
    if params[:action] == 'edit'
      "#sectionTitle#{@survey_section.id}"
    else
      "#survey_section_#{params[:prev_section_id]}"
    end

  end

  def form_handler
    if params[:action] == 'new'
      "sectionAddHandler"
    end
  end

end