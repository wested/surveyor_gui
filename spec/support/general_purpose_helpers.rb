module GeneralPurposeHelpers

  def tinymce_fill_in( editor_id, options = {} )
    # editor_id = id of the textarea using tinyMCE

    page.execute_script("tinyMCE.get('#{editor_id}').setContent('#{options[:with]}')")

    if options[:with] == ''
      # Empty textarea content explicitly
      page.execute_script("$('##{editor_id}').val('')")
    end

  end

  def tinymce_fill_in_explicitly( editor_id, options = {} )
    # editor_id = id of the textarea using tinyMCE

    # Empty textarea content explicitly
    page.execute_script("$('##{editor_id}').val('#{options[:with]}')")

  end

end
