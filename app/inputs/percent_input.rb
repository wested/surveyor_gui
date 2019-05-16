class PercentInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    "#{@builder.text_field(attribute_name, merge_wrapper_options(input_html_options, wrapper_options))}%".html_safe
  end
end
