require 'spec_helper'
#from spec/support/surveyforms_helpers.rb
include SurveyFormsCreationHelpers::CreateSurvey
include SurveyFormsCreationHelpers::BuildASurvey

feature "User adds scores using browser", %q{
  As a user
  I want to add scores to answers on questions
  So that I can apply a scoring algorithm to determine how someone did on the quiz} do

  include_context "scores"

  scenario "user adds scores to pick one question", js: true do
    #Given I have a survey with two questions
    visit surveyor_gui.surveyforms_path
    # page.save_screenshot(File.join(Rails.root, "tmp", "hotel.png"), :full => true)
    expect(page).to have_content("Scores")
    within "tr", text: "Scores" do
      click_link "Edit"
    end

    expect(page).to have_content("What is your favorite color?")
    #And I click Add Logic on the second question
    within "fieldset.questions", text: "What is your favorite color?" do
      click_button "Scores"
    end

    wait_for_ajax

    #Then I see a window pop-up
    within ".modal" do
      expect(page).to have_content("red")
      expect(page).to have_content("blue")
      expect(page).to have_content("green")
      expect(page).to have_content("Other")

      fill_in "Other", with: 1
      fill_in "green", with: 2
      click_button "Save Changes"
    end

    wait_for_ajax

    within "fieldset.questions", text: "What is your favorite color?" do
      click_button "Scores"
    end

    wait_for_ajax

    within ".modal" do
      expect(page).to have_field('green', with: 2)
      expect(page).to have_field('Other', with: 1)

      click_button "Save Changes"
    end
  end

  scenario "user adds scores to pick any question", js: true do
    #Given I have a survey with two questions
    visit surveyor_gui.surveyforms_path
    # page.save_screenshot(File.join(Rails.root, "tmp", "hotel.png"), :full => true)
    expect(page).to have_content("Scores")
    within "tr", text: "Scores" do
      click_link "Edit"
    end

    expect(page).to have_content("Choose the colors you don't like")
    #And I click Add Logic on the second question
    within "fieldset.questions", text: "Choose the colors you don't like" do
      click_button "Scores"
    end

    wait_for_ajax

    #Then I see a window pop-up
    within ".modal" do
      expect(page).to have_content("orange")
      expect(page).to have_content("purple")
      expect(page).to have_content("brown")

      fill_in "orange", with: 1
      fill_in "purple", with: 2
      click_button "Save Changes"
    end

    wait_for_ajax

    within "fieldset.questions", text: "Choose the colors you don't like" do
      click_button "Scores"
    end

    wait_for_ajax

    within ".modal" do
      expect(page).to have_field('purple', with: 2)
      expect(page).to have_field('orange', with: 1)

      click_button "Save Changes"
    end
  end

  scenario "user adds scores to group question", js: true do
    #Given I have a survey with two questions
    visit surveyor_gui.surveyforms_path
    # page.save_screenshot(File.join(Rails.root, "tmp", "hotel.png"), :full => true)
    expect(page).to have_content("Scores")
    within "tr", text: "Scores" do
      click_link "Edit"
    end

    expect(page).to have_content("scoring in sub questions")
    #And I click Add Logic on the second question
    within "fieldset.questions .question_group_element", text: "What is your favorite animal?" do
      click_button "Scores"
    end

    wait_for_ajax

    #Then I see a window pop-up
    within ".modal" do
      expect(page).to have_content("dog")
      expect(page).to have_content("cat")
      expect(page).to have_content("bird")

      fill_in "dog", with: 1
      fill_in "cat", with: 2
      click_button "Save Changes"
    end

    wait_for_ajax

    within "fieldset.questions .question_group_element", text: "What is your favorite animal?" do
      click_button "Scores"
    end

    wait_for_ajax

    within ".modal" do
      expect(page).to have_field('cat', with: 2)
      expect(page).to have_field('dog', with: 1)

      click_button "Save Changes"
    end

    #And I click Add Logic on the second question
    within "fieldset.questions .question_group_element", text: "Choose the animals you don't like" do
      click_button "Scores"
    end

    wait_for_ajax

    #Then I see a window pop-up
    within ".modal" do
      expect(page).to have_content("reptile")
      expect(page).to have_content("rodent")

      fill_in "reptile", with: 1
      fill_in "rodent", with: 2
      click_button "Save Changes"
    end

    wait_for_ajax

    within "fieldset.questions .question_group_element", text: "Choose the animals you don't like" do
      click_button "Scores"
    end

    wait_for_ajax

    within ".modal" do
      expect(page).to have_field('rodent', with: 2)
      expect(page).to have_field('reptile', with: 1)

      click_button "Save Changes"
    end
  end
end
