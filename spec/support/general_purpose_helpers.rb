module GeneralPurposeHelpers
  def tinymce_fill_in( editor_id, options = {} )
    # editor_id = id of the textarea using tinyMCE
    expect(page).to have_xpath(%Q{//textarea[@id="#{editor_id}"]}, visible: false)
    page.execute_script("tinyMCE.get('#{editor_id}').setContent('#{options[:with]}')")

    if options[:with] == ''
      # Empty textarea content explicitly
      page.execute_script("$('##{editor_id}').val('')")
    end
  end

  def tinymce_fill_in_explicitly( editor_id, options = {} )
    # editor_id = id of the textarea using tinyMCE
    expect(page).to have_xpath(%Q{//textarea[@id="#{editor_id}"]}, visible: false)

    # Empty textarea content explicitly
    page.execute_script("$('##{editor_id}').val('#{options[:with]}')")
  end
end
