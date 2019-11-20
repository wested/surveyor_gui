require 'spec_helper'

include SurveyFormsCreationHelpers::CreateSurvey
include SurveyFormsCreationHelpers::BuildASurvey
include GeneralPurposeHelpers

feature "Cloning" do
  include_context "favorites"

  scenario "a template can be cloned" do
    # Given a template survey exists
    Survey.where(title: "Favorites").first.update_attribute(:template, true)

    #Given I'm on the surveyform web page
    visit surveyor_gui.surveyforms_path

    #When I click "Clone"
    click_link "Clone"

    # page.save_screenshot(File.join(Rails.root, "tmp", "surveyor.png"), :full => true)

    #Then I can edit cloned Survey
    expect(page).to have_content("Successfully created survey, questionnaire, or form")
    expect(page).to have_selector("input[value='Favorites CLONE']")
  end

  scenario "a survey cannot be cloned" do

    #Given I'm on the surveyform web page
    visit surveyor_gui.surveyforms_path
    expect(page).to have_content("Surveyor")
    # page.save_screenshot(File.join(Rails.root, "tmp", "surveyor.png"), :full => true)

    #When I see survey
    expect(page).to have_content("Favorites")

    #Then I cannot clone it
    expect(page).to_not have_link("Clone")
  end
end
