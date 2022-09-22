module SurveyorGui::ApplicationHelper
  def error_messages_for(object)
    count = object.errors.count
    if !count.zero?
      I18n.with_options(scope: [:surveyor_gui, :errors, :template]) do |locale|
        header_message = locale.t(:header, count: count, model: object.class.model_name.singular)

        message = locale.t(:body)

        error_messages = object.errors.full_messages.map do |msg|
          content_tag(:li, msg)
        end.join.html_safe

        contents  = ''
        contents << content_tag(:h2, header_message) unless header_message.blank?
        contents << content_tag(:p, message) unless message.blank?
        contents << content_tag(:ul, error_messages)
        content_tag(:div, contents.html_safe, { id: 'error_explanation', class: 'error_explanation' })
      end
    else
      ''
    end
  end
end
