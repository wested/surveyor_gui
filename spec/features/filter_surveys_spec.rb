require 'spec_helper'

include SurveyFormsCreationHelpers::CreateSurvey
include SurveyFormsCreationHelpers::BuildASurvey
include GeneralPurposeHelpers

feature "Filter Surveys" do
  include_context "everything"
  include_context "favorites"

  before(:each) do
    Survey.where(title: "Favorites").first.update_attribute(:template, true)
  end

  scenario "by default all are displayed" do

    #Given I'm on the surveyform web page
    visit surveyor_gui.surveyforms_path

    #When filter 'All' is selected
    expect(page).to have_css(".btn-default.active", text: "All")
    expect(page).to have_content("Manage All Surveys")

    #Then I see both surveys
    expect(page).to have_content("Everything")
    expect(page).to have_content("Favorites")
  end

  scenario "clicking 'Surveys Only' filters to only surveys", js: true do

    #Given I'm on the surveyform web page
    visit surveyor_gui.surveyforms_path

    #page.save_screenshot(File.join(Rails.root, "tmp", "surveys_only.png"), :full => true)

    #When I click on filter 'Surveys Only'
    click_link "Surveys Only"

    #Then I see surveys only
    expect(page).to have_content("Manage Surveys Only")
    expect(page).to have_content("Everything")
    expect(page).to_not have_content("Favorites")
  end

  scenario "clicking 'Templates Only' filters to only templates" do

    #Given I'm on the surveyform web page
    visit surveyor_gui.surveyforms_path

    #When I click on filter 'Templates Only'
    click_link "Templates Only"

    #Then I see templates only
    expect(page).to have_content("Manage Templates Only")
    expect(page).to_not have_content("Everything")
    expect(page).to have_content("Favorites")
  end
end
