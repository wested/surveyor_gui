require 'spec_helper'

include SurveyFormsCreationHelpers::CreateSurvey
include SurveyFormsCreationHelpers::BuildASurvey
include GeneralPurposeHelpers

feature "Bug fix #41", %q{
  As a user
  I want to create a new survey using a browser
  And have some mandatory questions per issue #41
  And take the new survey successfully
} do

  scenario "make a public survey and take public survey", js: true do
    #Given I'm on the "Create New Survey" page
    visit surveyor_gui.new_surveyform_path

    #When I fill in a title
    fill_in "Title", with: "Public Survey"

    check "Public?"

    #And I save the survey
    click_button "Save Changes"

    #use the public route to take it
    visit "/surveys/public-survey/new"

    expect(page).to have_content("Public Survey")
    expect(page).to_not have_content("Access Denied")

  end

  scenario "make a non-public survey and CANNOT take public survey", js: true do
    #Given I'm on the "Create New Survey" page
    visit surveyor_gui.new_surveyform_path

    #When I fill in a title
    fill_in "Title", with: "Not Public Survey"

    #And I save the survey
    click_button "Save Changes"

    #use the public route to take it
    visit "/surveys/not-public-survey/new"

    expect(page).to have_content("Not Public Survey")
    expect(page).to have_content("Access Denied")

  end

  scenario "Make survey and take survey", :js => true do
      #Given I'm on the "Create New Survey" page
      visit surveyor_gui.new_surveyform_path

      #When I fill in a title
      fill_in "Title", with: "How was Boston?"

      #And I save the survey
      click_button "Save Changes"

      #Then I can start entering more details, like sections
      expect(page).to have_button "Add Section"

      #Given I've added a new question
      add_question do
        sleep 0.5
      #Then I select the "multiple choice" question type
        select_question_type "Multiple Choice (only one answer)"

      #And I frame the question
        tinymce_fill_in "question_text", with: "Was it snowing?"

      #And I make it mandatory
        check "question_is_mandatory"

      #And I add some choices"
        find(:css, "input.option-value", match: :first).set("Yes")
        click_link "Add Another Option"
        all("input.option-value").last.set("No")


      #And I save the question
        click_button "Save Changes"

      #Then the window goes away
      end

      #Then I can see the question in my survey
      page.save_screenshot(File.join(Rails.root, "tmp", "snowing.png"), :full => true)
      expect(first_question).to have_content("Was it snowing?")


      #Then I add another question
      add_question do
        sleep 0.5
      #Then I select the "Text" question type
        select_question_type "Text"

      #And I frame the question
        tinymce_fill_in "question_text", with: "Did you take the T?"

      #And I save the question
        click_button "Save Changes"

      #Then the window goes away
      end

      #And I can see the question in my survey
      expect(page).to have_content("Did you take the T?")

      #And I click Add Logic on the second question
      within "fieldset.questions", text: "Did you take the T?" do
        click_button "Add Logic"
      end
      #Then I see a window pop-up
      #And it has logic, which defaults to checking the first question for the answer "yes"
      within ".modal" do
        expect(page).to have_content("conditions")
        expect(page).to have_css("option", text: 'Was it snowing?')
        expect(page).to have_css("option", text: 'equal to')
        page.save_screenshot(File.join(Rails.root, "tmp", "logic.png"), :full => true)
        select('No', from: 'question_dependency_attributes_dependency_conditions_attributes_0_answer_id')
        click_button "Save Changes"
      end

      #Then I add another question
      wait_for_ajax
      add_question do
        sleep 0.5
      #Then I select the "Text" question type
        select_question_type "Text"

      #And I frame the question
        tinymce_fill_in "question_text", with: "Was the T running?"

      #And I make it mandatory
        check "question_is_mandatory"

      #And I save the question
        click_button "Save Changes"

      #Then the window goes away
      end

      #And I can see the question in my survey
      expect(page).to have_content("Was the T running?")

      #And I click Add Logic on the second question
      within "fieldset.questions", text: "Was the T running?" do
        click_button "Add Logic"
      end
      #Then I see a window pop-up
      within ".modal" do
        #And it has logic, which defaults to checking the first question for the answer "yes"
        expect(page).to have_content("conditions")
        expect(page).to have_css("option", text: 'Was it snowing?')
        expect(page).to have_css("option", text: 'equal to')
        select('Yes', from: 'question_dependency_attributes_dependency_conditions_attributes_0_answer_id')
        click_button "Save Changes"
      end

      #When I visit the take surveys url
      visit surveyor.available_surveys_path

      #And I see the new survey
      expect(page).to have_content("How was Boston?")

      #And I click the take it button
      click_button "Take it"

      #Then I see a question
      expect(page).to have_content("Was it snowing?")

      #When I click finish
      click_button "Click here to finish"

      #Then I am prevented from continuing and told of mandatory question
      expect(page).to have_content("You must complete all required fields")

      expect(page).to have_content("Was it snowing?")

      #And I don't see the other questions yet
      expect(page).to_not have_content("Did you take the T?")

      expect(page).to_not have_content("Was the T running?")

      #Then I change the answer to "No"
      no = Answer.find_by text: "No"
      within_fieldset('1) ') do
        find("input[value='#{no.id}']").trigger('click')
      end

      #Then I see a question, 'Did you take the T?'
      expect(page).to have_content("Did you take the T?")

      #When I click finish
      click_button "Click here to finish"

      #Then I can save successfully and return to the available surveys page
      expect(page).to have_content("You may take these surveys")

      #And I take the survey again
      click_button "Take it"

      #Then I see a question
      expect(page).to have_content("Was it snowing?")

      #Then I change the answer to "No"
      yes = Answer.find_by text: "Yes"
      within_fieldset('1) ') do
        find("input[value='#{yes.id}']").trigger('click')
      end

      #When I click finish
      click_button "Click here to finish"

      #Then I am prevented from continuing and told of mandatory question
      # DAH!! this intermittently fails!!
      wait_for_ajax
      expect(page).to have_content("You must complete all required fields")

      expect(page).to have_content("Was the T running?")

      # DAH!! this intermittently fails!!
      #Then I fill in an answer to the mandatory question
      find("r_3_string_value")
      fill_in "r_3_string_value", with: "It was"

      #When I click finish
      click_button "Click here to finish"

      #Then I can save successfully and return to the available surveys page
      expect(page).to have_content("You may take these surveys")
  end
end
