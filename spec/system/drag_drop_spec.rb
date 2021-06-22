require 'spec_helper'

#from spec/support/surveyforms_helpers.rb
include SurveyFormsCreationHelpers::CreateSurvey
include SurveyFormsCreationHelpers::BuildASurvey
include SurveyFormsCreationHelpers::DragDrop
include GeneralPurposeHelpers

describe "Survey Creator drag/drop", type: :system, js: true, headless_selenium: true do

  context "drag/drops answers in order to reorder them" do
    before :each do
      build_a_small_survey_for_drag_drop
    end

    scenario "for a question in a section" do

      expect(page).to have_content("Deluxe King\nStandard Queen\nStandard Double")

      question = Question.find_by(text: "<p>What type of room did you get?</p>")
      last_answer = question.answers.last

      expect(last_answer.display_order).to eq 2

      within find("#question_#{question.id}") do
        click_link "Edit Question"
      end

      find("#sortable_answers")

      #When I move last answer up by 1 position
      sortables = all('.ui-sortable-handle')

      drag_and_drop_item_above(sortables[2], sortables[1])

      click_button "Save Changes"

      expect(page).to have_content("Deluxe King\nStandard Double\nStandard Queen")

      expect(last_answer.reload.display_order).to eq 1

    end

    scenario "for a question in a question group" do

      expect(page).to have_content("Pants\nDresses\nShorts")

      question = Question.find_by(text: "<p>My favorite thing to wear is?</p>")
      last_answer = question.answers.last

      expect(last_answer.display_order).to eq 2

      within find("#question_#{question.id}") do
        click_link "Edit Question"
      end

      within "#answers" do

        #When I move last answer up by 1 position
        sortables = all('.ui-sortable-handle')

        drag_and_drop_item_above(sortables[2], sortables[1])
      end

      click_button "Save Changes"

      expect(page).to have_content("Pants\nShorts\nDresses")

      # page.save_screenshot(File.join(Rails.root, "tmp", "drag_drop_answers.png"), :full => true)
      expect(last_answer.reload.display_order).to eq 1

    end
  end

  context "drag/drops questions in order to reorder them" do
    before :each do
      build_a_small_survey_for_drag_drop
    end

    scenario "for a question in a section" do

      question = Question.find_by(text: "<p>What type of room did you get?</p>")

      expect(page.body).to match(/Describe your day at Fenway Park.*How many days did you stay.*What type of room did you get/m)

      expect(question.display_order).to eq 3

      within ".sortable_questions", match: :first do

        #When I move last answer up by 1 position
        sortables = all('.ui-sortable-handle')

        drag_and_drop_item_above(sortables[2], sortables[1])

        # page.save_screenshot(File.join(Rails.root, "tmp", "drag_drop_answers.png"), :full => true)
        expect(page.body).to match(/Describe your day at Fenway Park.*What type of room did you get.*How many days did you stay/m)

        expect(question.reload.display_order).to eq 2
      end

    end

    scenario "for a question in a question group" do

      question_group = QuestionGroup.find_by(text: "<p>Question Group Test</p>")
      first_question = question_group.questions.first
      last_question = question_group.questions.last

      expect(page.body).to match(/My favorite thing to wear is?.*Just need another question here for drag\/drop test/m)

      expect(last_question.display_order).to eq 5

      page.save_screenshot(File.join(Rails.root, "tmp", "drag_drop_answers.png"), :full => true)

      within find("#question_#{first_question.id}") do
        click_link "Edit Question"
      end

      within ".group_inline", match: :first do

        #When I move last answer up by 1 position
        sortables = all('.handle.ui-sortable-handle')

        drag_and_drop_item_above(sortables[1], sortables[0])

      end

      click_button "Save Changes"

      # page.save_screenshot(File.join(Rails.root, "tmp", "drag_drop_answers.png"), :full => true)
      expect(page.body).to match(/Just need another question here for drag\/drop test.*My favorite thing to wear is?/m)

      expect(last_question.reload.display_order).to eq 4

    end
  end

end
