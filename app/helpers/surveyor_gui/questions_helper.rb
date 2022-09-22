module SurveyorGui::QuestionsHelper
  include SurveyorGui::ApplicationHelper

  def link_to_remove_fields (name, f, dom_to_hide=nil)
    f.hidden_field(:_destroy) + link_to(image_tag("delete.png",:border => 0, :margin=>'-1em'), "#", onclick: "remove_fields(this, \"#{dom_to_hide}\");")
  end

  def adjusted_text(question)
    if question.is_a?(Question)
      if question.part_of_group?
        question.question_group.text
      else
        question.text
      end
    else
      question.new_record? ? params[:text] : question.text
    end
  end

  def question_type_subset(args)
    question_types = QuestionType.all.map{|t|[t.text, t.id]}[0..19].uniq
    ordered_types = []
    args.each do |id|
      ordered_types << question_types.select{|t| id == t[1]}.flatten
    end
    ordered_types
  end
end
