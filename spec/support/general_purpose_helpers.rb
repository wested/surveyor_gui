module GeneralPurposeHelpers
  def tinymce_fill_in( editor_id, options = {} )
    # editor_id = id of the textarea using tinyMCE
    expect(page).to have_xpath(%Q{//textarea[@id="#{editor_id}"]}, visible: false)
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until page.evaluate_script("window.tinymceReady")
    end
    page.execute_script("tinymce.get('#{editor_id}').setContent('#{options[:with]}')")

    if options[:with] == ''
      # Empty textarea content explicitly
      page.execute_script("$('##{editor_id}').val('')")
    end
  end

  def tinymce_fill_in_explicitly( editor_id, options = {} )
    # editor_id = id of the textarea using tinyMCE
    expect(page).to have_xpath(%Q{//textarea[@id="#{editor_id}"]}, visible: false)
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until page.evaluate_script("window.tinymceReady")
    end

    # Empty textarea content explicitly
    page.execute_script("$('##{editor_id}').val('#{options[:with]}')")
  end
end
