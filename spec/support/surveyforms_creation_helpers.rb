module SurveyFormsCreationHelpers
  module CreateSurvey
    def start_a_new_survey
      visit surveyor_gui.new_surveyform_path
      fill_in "Title", with: "How was Boston?"
      click_button "Save Changes"
    end

    def first_section_title
      find('.survey_section h2')
    end

    def first_question
      find('.questions', match: :first)
    end

    def add_question(&block)
      #make sure prior jquery was completed
      expect(page).not_to have_css('div.jquery_add_question_started, div.jquery_add_section_started')

      #page.save_screenshot(File.join(Rails.root, "tmp", "build_survey_click.png"), :full => true)
      all('.add-question').last.click

      find('form')
      expect(find('h1')).to have_content("Add Question")
      #then enter the question details
      block.call
      #then the window closes

      # wait_for_ajax
      expect(page).not_to have_css('div.jquery_add_question_started')
    end

    def add_section

      find('#add_section', match: :first)
      click_button "Add Section", match: :first

    end

    def fix_node_error(&block)
      # fix Capybara::Poltergeist::ObsoleteNode: - seems like some kind of race problem
      begin
        yield(block)
      rescue
        sleep(2)
        yield(block)
      end
    end

    def select_question_type(type)
      #within ".question_type" do
        choose(type)
      #end
    end

    def add_answers
      wait_for_ajax
      page.all("div.answer .question_answers_text input")
    end
  end

  module BuildASurvey
    def build_a_survey
      #Given I'm on the "Create New Survey" page
      visit surveyor_gui.new_surveyform_path

      title_the_survey
      title_the_first_section
      add_a_text_question("Describe your day at Fenway Park.")
      add_a_number_question
      add_a_pick_one_question
      add_a_pick_any_question
      add_a_dropdown_question
      add_a_date_question
      add_a_label
      add_a_slider_question
      add_a_star_question
      add_a_file_upload

      add_a_new_section("Entertainment")
      question_maker = QuestionsFactory.new
      question_maker.make_question(3){|text| add_a_text_question(text)}
      add_a_text_question("Describe your room.")

      add_a_new_section("Food")
      question_maker.make_question(3){|text| add_a_text_question(text)}
    end

    def build_a_small_survey_for_drag_drop
      #Given I'm on the "Create New Survey" page
      visit surveyor_gui.new_surveyform_path

      title_the_survey
      title_the_first_section
      add_a_text_question("Describe your day at Fenway Park.")
      add_a_number_question
      add_a_pick_one_question
      add_a_pick_one_question_in_question_group

      add_a_new_section("Entertainment")

    end


    def build_a_three_question_survey
      visit surveyor_gui.new_surveyform_path
      title_the_survey
      question_maker = QuestionsFactory.new
      question_maker.make_question(3){|text| add_a_text_question(text)}
    end

    def build_a_three_section_survey
      visit surveyor_gui.new_surveyform_path
      title_the_survey
      title_the_first_section ("Unique Section 1")
      add_a_new_section("Unique Section 2")
      add_a_new_section("Unique Section 3")
    end

    def title_the_survey
      #When I fill in a title
      fill_in "Title", with: "How was Boston?"
      #And I save the survey
      click_button "Save Changes"
    end

    def title_the_first_section(title="Accommodations")
      #And I click "Edit Section Title"
      click_link "Edit Section Title"

      find(".modal")
      #Then I see a window pop-up
      expect(page).to have_css('.modal form')
      within ".modal form" do
      #And I enter a title
        fill_in "Title", with: title
      #And I save the title
        click_button "Save Changes"
      end
    end

    def add_a_text_question(text="Where did you stay?")
      add_question do
      #And I see a new form for "Add Question"
        find('form')
        expect(find('h1')).to have_content("Add Question")
      sleep 0.5
      #And I frame the question
        tinymce_fill_in "question_text", with: text
      #And I select the "text" question type
        select_question_type "Text"
      #And I save the question
        click_button "Save Changes"
      #Then the window goes away
      end

      #page.save_screenshot(File.join(Rails.root, "tmp", "build_survey.png"), :full => true)
    end

    def add_a_number_question
      add_question do
        sleep 0.5
      #Given I've added a new question
      #Then I select the "number" question type
        select_question_type "Number"
      #And I frame the question
        tinymce_fill_in "question_text", with: "How many days did you stay?"
      #And I add the suffix, "days"
        fill_in "question_suffix", with: "days"
      #And I sav the question
        click_button "Save Changes"
      #Then the window goes away
      end
    end

    def add_a_pick_one_question
      add_question do
        sleep 0.5
      #Then I select the "multiple choice" question type
        select_question_type "Multiple Choice (only one answer)"
      #And I frame the question
        tinymce_fill_in "question_text", with: "What type of room did you get?"
      #And I add some choices"
        find(:css, "input.option-value", match: :first).set("Deluxe King")
        click_link "Add Another Option"
        all("input.option-value").last.set("Standard Queen")
        click_link "Add Another Option"
        all("input.option-value").last.set("Standard Double")
      #And I save the question
        click_button "Save Changes"
      #Then the window goes away
      end

    end

    def add_a_pick_one_question_in_question_group
      add_question do
        sleep 0.5
        #Then I select the "question group" question type
        select_question_type "Question Group"
        #And I frame the question
        tinymce_fill_in "question_group_text", with: "Question Group Test"
        #And I frame the question
        tinymce_fill_in "question_group_questions_attributes_0_text", with: "My favorite thing to wear is?"
        select "Multiple Choice (only one answer)", :from => "question_group_questions_attributes_0_question_type_id"
        #And I add some choices"
        find(:css, "input.option-value", match: :first).set("Pants")
        click_link "Add Another Option"
        all("input.option-value").last.set("Dresses")
        click_link "Add Another Option"
        all("input.option-value").last.set("Shorts")
        #And I save the question
        #
        # click_link "Add Question"
        find(".add_group_inline_question").click

        within all('.sortable_group_questions').last do
          tinymce_fill_in "question_group_questions_attributes_2_text", with: "Just need another question here for drag/drop test"
        end
        click_button "Save Changes"
        #Then the window goes away
      end

    end

    def add_a_text_question_in_inline_question_group
      add_question do
        sleep 0.5
        #Then I select the "question group" question type
        select_question_type "Inline Question Group"
        #And I frame the question
        tinymce_fill_in "question_group_text", with: "Inline Question Group Test"
        #And I frame the question
        tinymce_fill_in "question_group_questions_attributes_0_text", with: "Give me your thoughts Inline?"

        click_button "Save Changes"
        #Then the window goes away
      end

    end

    def add_a_pick_any_question
      #Given I've added a new question
      add_question do
        sleep 0.5
      #Then I select the "number" question type
        select_question_type "Multiple Choice (multiple answers)"
      #And I frame the question
        tinymce_fill_in "question_text", with: "What did you order from the minibar?"
      #And I add some choices"
        find(:css, "input.option-value", match: :first).set("Bottled Water")
        click_link "Add Another Option"
        all("input.option-value").last.set("Kit Kats")
        click_link "Add Another Option"
        all("input.option-value").last.set("Scotch")
      #And I save the question
        click_button "Save Changes"
      #Then the window goes away
      end
    end

    def add_a_dropdown_question
      #Given I've added a new question
      add_question do
        sleep 0.5
      #Then I select the "number" question type
        select_question_type "Dropdown List"
      #And I frame the question
        tinymce_fill_in "question_text", with: "What neighborhood were you in?"
      #And I add some choices"
        find(:css, "input.option-value", match: :first).set("Financial District")
        click_link "Add Another Option"
        all("input.option-value").last.set("Back Bay")
        click_link "Add Another Option"
        all("input.option-value").last.set("North End")

      #And I save the question
        click_button "Save Changes"
      #Then the window goes away
      end
    end

    def add_a_date_question
      #And I can see the question in my survey
      #Given I've added a new question
      add_question do
        sleep 0.5
      #Then I select the "number" question type
        select_question_type "Date"
      #And I frame the question
        tinymce_fill_in "question_text", with: "When did you checkout?"
      #And I save the question
        click_button "Save Changes"
      #Then the window goes away
      end
    end

    def add_a_label
      add_question do
        sleep 0.5
      #Then I select the "Label" question type
        select_question_type "Label"
      #And I frame the question
        tinymce_fill_in "question_text", with: "You do not need to answer the following questions if you are not comfortable."
      #And I save the question
        click_button "Save Changes"
      #Then the window goes away
      end
    end

    def add_a_text_box_question
      #Given I've added a new question
      add_question do
        sleep 0.5
      #Then I select the "Text Box" question type
        select_question_type "Text Box (for extended text, like notes, etc.)"
      #And I frame the question
        tinymce_fill_in "question_text", with: "What did you think of the staff?"
      #And I save the question
        click_button "Save Changes"
      #Then the window goes away
      end
    end

    def add_a_slider_question
      #Given I've added a new question
      add_question do
        sleep 0.5
      #Then I select the "Slider" question type
        select_question_type "Slider"
      #And I frame the question
        tinymce_fill_in "question_text", with: "What did you think of the food?"
      #And I add some choices"
        find(:css, "input.option-value", match: :first).set("Sucked!")
        click_link "Add Another Option"
        all("input.option-value").last.set("Meh")
        click_link "Add Another Option"
        all("input.option-value").last.set("Good")
        click_link "Add Another Option"
        all("input.option-value").last.set("Wicked good!")
      #And I save the question
        click_button "Save Changes"
      #Then the window goes away
      end
    end

    def add_a_star_question
      #Given I've added a new question
      add_question do
        sleep 0.5
      #Then I select the "Star" question type
        select_question_type "Star"
      #And I frame the question
        tinymce_fill_in "question_text", with: "How would you rate your stay?"
      #And I save the question
        click_button "Save Changes"
      #Then the window goes away
      end
    end

    def add_a_file_upload
      #Given I've added a new question
      add_question do
        sleep 0.5
      #Then I select the "Star" question type
        select_question_type "File Upload"
      #And I frame the question
        tinymce_fill_in "question_text", with: "Please upload a copy of your bill."
      #And I save the question
        click_button "Save Changes"
      #Then the window goes away
      end
    end

    def add_a_new_section(title)
      #Then I add Section II
      add_section
      within ".modal" do
        fill_in "Title", with: title
        click_button "Save Changes"
      end
    end

    class QuestionsFactory
      attr_reader :question_no
      def initialize
        @question_no = 1
      end

      def make_question(quantity,&block)
        quantity.times do
          block.call("Unique Question "+@question_no.to_s)
          @question_no += 1
        end
      end
    end
  end

  module DragDrop
    def drag_and_drop_item_above(item, to_above)
      selenium_webdriver = page.driver.browser
      selenium_webdriver.action
                        .click_and_hold(item.native)
                        .move_to(to_above.native, 0, 10)
                        .release
                        .perform
      sleep 0.5
    end
  end
end
