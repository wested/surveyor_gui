module SurveyorGui
  module Models
    module QuestionTypeMethods

      attr_accessor :id, :text, :part_of_group, :pick, :display_type, :group_display_type, :response_class

      def initialize(args)
        @id                 = args[:id]
        @text               = args[:text]
        @part_of_group      = args[:part_of_group]
        @pick               = args[:pick]
        @display_type       = args[:display_type]
        @group_display_type = args[:group_display_type]
        @response_class     = args[:response_class]
      end

      def self.included(base)
        base.send :extend, ClassMethods
      end

      def persisted?
        false
      end

      def grid?
        @id == :grid_one || @id == :grid_any
      end

      def grid_one?
        @id == :grid_one
      end

      def build_complex_question_structure(question, args)
        #looks at id and calls the appropriate methods, eg.
        #if question_type.id is pick_one, calls _build_pick_one
        question.reload
        #puts question.attributes
        builder = "_build_"+id.to_s
        send builder.to_sym, question, args
      end

      # rails 6 upgrade requiring this function....
      def marked_for_destruction?

      end

      def process_answer_options(question, args)
        is_exclusive  = args[:is_exclusive]
        other         = args[:other]
        is_comment    = args[:comments]
        omit_text     = is_exclusive ? "\n"+args[:omit_text].to_s : ""
        other_text    = other        ? "\n"+args[:other_text].to_s : ""
        comments_text = is_comment   ? "\n"+args[:comments_text].to_s : ""

        _create_an_other_answer(question, other, other_text)
        _create_an_omit_answer(question, is_exclusive, omit_text)
        _create_a_comment_answer(question, is_comment, comments_text)
      end

      private

      def _build_pick_one(question, args)
        _process_answers_textbox(question, args)
      end

      def _build_pick_any(question, args)
        _process_answers_textbox(question, args)
      end

      def _build_slider(question, args)
        _process_answers_textbox(question, args)
      end

      def _build_stars(question, args)
      end

      def _build_dropdown(question, args)
        _process_answers_textbox(question, args)
      end

      def _build_grid_one(question, args)
        _build_grid(question,args)
      end

      def _build_grid_any(question, args)
        _build_grid(question,args)
      end

      def _build_grid_dropdown(question, args)
        _build_grid_dropdown(question,args)
      end

      def _build_grid(question,args)
        is_exclusive          = args[:is_exclusive]
        omit_text             = args[:omit_text].to_s
        grid_columns_textbox  = args[:grid_columns_textbox]
        grid_rows_textbox     = args[:grid_rows_textbox]
        other                 = args[:other]
        other_text            = args[:other_text].to_s
        is_comment            = args[:comments]
        comments_text         = args[:comments_text].to_s
        _cleanup_orphan_grid_dropdown_answers(question)
        _process_grid_rows_textbox(question, grid_rows_textbox)
        _process_grid_answers(
          question,
          grid_columns_textbox,
          is_exclusive, omit_text,
          other, other_text,
          is_comment, comments_text
        )
        _restore_question_group(question)
      end

      def _build_grid_dropdown(question,args)
        is_exclusive          = args[:is_exclusive]
        omit_text             = args[:omit_text].to_s
        grid_columns_textbox  = args[:grid_columns_textbox]
        grid_rows_textbox     = args[:grid_rows_textbox]
        other                 = args[:other]
        other_text            = args[:other_text].to_s
        is_comment            = args[:comments]
        comments_text         = args[:comments_text].to_s
        _process_grid_rows_textbox(question, grid_rows_textbox)
        _process_grid_columns_textbox(
          question,
          is_exclusive, omit_text,
          other, other_text,
          is_comment, comments_text
        )
        _create_a_comment(question, is_comment, comments_text)
        _restore_question_group(question)
      end

      def _process_answers_textbox(question, args)
        answers_textbox   = args[:answers_textbox]

        if answers_textbox.present?
          updated_answers = TextBoxParser.new(
            textbox: answers_textbox,
            records_to_update: question.answers
          )
          updated_answers.update_or_create_records do |display_order, text|
            _create_an_answer(display_order, text, question)
          end
        end

        process_answer_options(question, args)
      end

      def _process_grid_rows_textbox(
        question,
        grid_rows_textbox
      )
        #puts "processing grid rows \ntextbox grid?: #{_grid?(question)} \ntb: #{grid_rows_textbox} \ntb: #{grid_columns_textbox}\nthis: #{question.id}\ntext: #{question.text}"
        #puts 'got to inner if'
        #puts "\n\n#{question.display_order}\n\n"
        display_order_of_first_question_in_group = question.display_order
        grid_rows = TextBoxParser.new(
          textbox: grid_rows_textbox,
          records_to_update: question.question_group.questions,
          starting_display_order: display_order_of_first_question_in_group
        )
        grid_rows.update_or_create_records(pick: question.pick, display_type: question.display_type) \
         do |display_order, new_text|
          current_question = _create_a_question(question, display_order, new_text)
          #puts "current question: #{current_question.text} #{current_question.question_group_id} saved? #{current_question.persisted?} id: #{current_question.id}"
        end
      end

      def _process_grid_answers(
        question,
        grid_columns_textbox,
        is_exclusive, omit_text,
        other, other_text,
        is_comment, comments_text,
        column_id=nil
      )
        question.question_group.questions.is_not_comment.each do |question|
          _create_some_answers(question, grid_columns_textbox, column_id)
          _create_an_other_answer(question, other, other_text, column_id)
          _create_an_omit_answer(question, is_exclusive, omit_text)
        end
        _create_a_comment(question, is_comment, comments_text) if id != :grid_dropdown
      end

      def _cleanup_orphan_grid_dropdown_answers(question)
        if question.question_group
          question.question_group.questions.map{|q| q.answers.where('column_id IS NOT NULL').map{|a| a.destroy}}
          question.question_group.columns.map{|c| c.destroy}
        end
      end

      def _restore_question_group(question)
        #work around for infernal :dependent=>:destroy on belongs_to :question_group from Surveyor
        #can't seem to override it and everytime a question is deleted, the whole group goes with it.
        #which makes it impossible to delete a question from a grid.
        begin
          QuestionGroup.find(question.question_group.id)
        rescue
          QuestionGroup.create!(question.question_group.attributes)
        end
      end

      def _process_grid_columns_textbox(
        question,
        is_exclusive,         omit_text,
        other,                other_text,
        is_comment,           comments_text
      )
        question.question_group.columns.each do |column|
          _process_grid_answers(
            question,
            column.answers_textbox,
            is_exclusive, omit_text,
            other, other_text,
            is_comment, comments_text,
            column.id
          )
        end
      end

      def _pick?
        !(pick=="none")
      end

      def _grid?(question)
        [:grid_one, :grid_any, :grid_dropdown].include? self.id
      end

      def _create_some_answers(current_question, grid_columns_textbox, column_id)
        if grid_columns_textbox.nil?
          grid_columns_textbox = " "
        end
        columns = TextBoxParser.new(
          textbox: grid_columns_textbox,
          records_to_update: current_question.answers.where('column_id=? or column_id IS NULL',column_id)
        )
        columns.update_or_create_records do |display_order, text|
          _create_an_answer(display_order, text, current_question, column_id: column_id)
        end

      end


      def _create_an_answer(display_order, new_text, current_question, args={})
        params = {
          question_id: current_question.id,
          text: new_text
        }.merge(args)

        if display_order
          params.merge!( { display_order: display_order } )
        end
        # If the answer text is a URL then that means the answer is an image
        if new_text =~ /\A#{URI::regexp(['http', 'https'])}\z/
          params.merge!( { display_type: "image", custom_class: "image-answer" } )
        end

        Answer.create!(params)
      end

      def _create_an_other_answer(question, other, other_text, column_id=nil)
        display_order = question.answers.last.display_order+1 if question.answers.last&.display_order.present?

        if other && question.answers.is_other.count == 0
          _create_an_answer(display_order, other_text, question, response_class: "string", column_id: column_id)
        elsif other
          question.answers.is_other.first&.update!(text: other_text, display_order: display_order)
        elsif !other && question.answers.is_other.count == 1
          question.answers.is_other.first.destroy!
        end
      end

      def _create_an_omit_answer(question, is_exclusive, omit_text)
        display_order = question.answers.last.display_order+1 if question.answers.last&.display_order.present?

        if is_exclusive && question.answers.is_omit.count == 0
          _create_an_answer(display_order, omit_text, question, is_exclusive: is_exclusive)
        elsif is_exclusive
          question.answers.is_omit.first&.update!(text: omit_text, display_order: display_order)
        elsif !is_exclusive && question.answers.is_omit.count == 1
          question.answers.is_omit.first.destroy!
        end
      end

      def _create_a_comment_answer(question, is_comment, comments_text)
        display_order = question.answers.last.display_order+1 if question.answers.last&.display_order.present?

        if is_comment && question.answers.is_comment.count == 0
          _create_an_answer(display_order, comments_text, question, response_class: "string", is_comment: true)
        elsif is_comment
          question.answers.is_comment.first&.update!(text: comments_text, display_order: display_order)
        elsif !is_comment && question.answers.is_comment.count == 1
          question.answers.is_comment.first.destroy!
        end
      end

      def _create_a_comment(question, is_comment, comments_text)
        if is_comment
          display_order = question.next_display_order
          question = _create_a_question(question, display_order,comments_text,  is_comment: true, pick: "none", display_type: "default")
          answer = _create_an_answer(0, comments_text, question, response_class: "string")
          answer.update_attribute(:text, "")
        end
      end

      def _create_a_question(question, display_order, new_text, args={})
        #puts "making question #{new_text}"
        #puts "\n\n#{self.display_order}\n\n"
        params = {
          display_order:        display_order,
          text:                 new_text,
          survey_section_id:    question.survey_section_id,
          question_group_id:    question.question_group_id,
          pick:                 question.pick,
          reference_identifier: question.reference_identifier,
          display_type:         question.display_type,
          is_mandatory:         question.is_mandatory,
          prefix:               question.prefix,
          suffix:               question.suffix,
          decimals:             question.decimals,
          modifiable:           question.modifiable,
          report_code:          question.report_code
        }.merge(args)
        return Question.create!(params)
      end


      #----------------------------- end instance methods ---------------------------------------------------------------
      module ClassMethods

        AllTypes = [
          #                                                                                             group       answer
          #                                                                   part_of_         display  display     response
          #id               #text                                             group?    pick   type     type        class
          [:pick_one,       "Multiple Choice (only one answer)"               , false,  :one,  "default", nil,      :all],
          [:pick_any,       "Multiple Choice (multiple answers)"              , false,  :any,  "default", nil,      :all],
          [:box,            "Text Box (for notes, etc.)"                      , false,  :none, "default", nil,      :text],
          [:dropdown,       "Dropdown List"                                   , false,  :one,  :dropdown, nil,      :all],
          [:string,         "Text"                                            , false,  :none, "default", nil,      :string],
          [:number,         "Number"                                          , false,  :none, "default", nil,      :float],
          [:number,         "Number"                                          , false,  :none, "default", nil,      :integer],
          [:date,           "Date"                                            , false,  :none, "default", nil,      :date],
          [:datetime,       "Date and Time"                                   , false,  :none, "default", nil,      :datetime],
          [:time,           "Time"                                            , false,  :none, "default", nil,      :time],
          [:slider,         "Slider"                                          , false,  :one,  :slider,   nil,      :all],
          [:stars,          "1-5 Stars"                                       , false,  :one,  :stars,    nil,      :all],
          [:label,          "Label"                                           , false,  :none, :label,    nil,      :all],
          [:file,           "File Upload"                                     , false,  :none, "default", nil,      :blob],
          [:grid_one,       "Grid (pick one)"                                 , true,   :one,  "default", :grid,    :all],
          [:grid_any,       "Grid (pick any)"                                 , true,   :any,  "default", :grid,    :all],
          [:grid_dropdown,  "Grid (dropdowns)"                                , true,   :one,  :dropdown, :grid,    :all],
          [:group_inline,   "Inline Question Group"                           , true,   nil,   nil,       :inline,  :all],
          [:group_default,  "Question Group"                                  , true,   nil,   nil,       :default, :all],
          [:repeater,       "Repeater (multiple responses)"                   , true,   nil,  :all,       :repeater, :all],
          #nothing below here shows up on the question builder choices for question type
          [:pick_one,       "Multiple Choice (only one answer)"               , true,   :one,  "default", :inline,  :all],
          [:pick_any,       "Multiple Choice (multiple answers)"              , true,   :any,  "default", :inline,  :all],
          [:box,            "Text Box (for extended text, like notes, etc.)"  , true,  :none, "default", :inline,  :text],
          [:dropdown,       "Dropdown List"                                   , true,  :one,  :dropdown, :inline,  :all],
          [:string,         "Text"                                            , true,  :none, "default", :inline,  :string],
          [:number,         "Number"                                          , true,  :none, "default", :inline,  :float],
          [:number,         "Number"                                          , true,  :none, "default", :inline,  :integer],
          [:date,           "Date"                                            , true,  :none, "default", :inline,  :date],
          [:datetime,       "Date and Time"                                   , true,  :none, "default", :inline,  :datetime],
          [:time,           "Time"                                            , true,  :none, "default", :inline,  :time],
          [:slider,         "Slider"                                          , true,  :one,  :slider,   :inline,  :all],
          [:stars,          "1-5 Stars"                                       , true,  :one,  :stars,    :inline,  :all],
          [:label,          "Label"                                           , true,  :none, :label,    :inline,  :all],
          [:file,           "File Upload"                                     , true,  :none, "default", :inline,  :blob],
          [:string,         "Text"                                            , true,  :none, :default,  :grid,    :all],


          [:pick_one,       "Multiple Choice (only one answer)"               , true,   :one,  "default",:default,  :all],
          [:pick_any,       "Multiple Choice (multiple answers)"              , true,   :any,  "default",:default,  :all],
          [:box,            "Text Box (for extended text, like notes, etc.)"  , true,  :none, "default", :default,  :text],
          [:dropdown,       "Dropdown List"                                   , true,  :one,  :dropdown, :default,  :all],
          [:string,         "Text"                                            , true,  :none, "default", :default,  :string],
          [:number,         "Number"                                          , true,  :none, "default", :default,  :float],
          [:number,         "Number"                                          , true,  :none, "default", :default,  :integer],
          [:date,           "Date"                                            , true,  :none, "default", :default,  :date],
          [:datetime,       "Date and Time"                                   , true,  :none, "default", :default,  :datetime],
          [:time,           "Time"                                            , true,  :none, "default", :default,  :time],
          [:slider,         "Slider"                                          , true,  :one,  :slider,   :default,  :all],
          [:stars,          "1-5 Stars"                                       , true,  :one,  :stars,    :default,  :all],
          [:label,          "Label"                                           , true,  :none, :label,    :default,  :all],
          [:file,           "File Upload"                                     , true,  :none, "default", :default,  :blob],

          [:pick_one,       "Multiple Choice (only one answer)"               , true,   :one,  "default",:repeater,  :all],
          [:pick_any,       "Multiple Choice (multiple answers)"              , true,   :any,  "default",:repeater,  :all],
          [:box,            "Text Box (for extended text, like notes, etc.)"  , true,  :none, "default", :repeater,  :text],
          [:dropdown,       "Dropdown List"                                   , true,  :one,  :dropdown, :repeater,  :all],
          [:string,         "Text"                                            , true,  :none, "default", :repeater,  :string],
          [:number,         "Number"                                          , true,  :none, "default", :repeater,  :float],
          [:number,         "Number"                                          , true,  :none, "default", :repeater,  :integer],
          [:date,           "Date"                                            , true,  :none, "default", :repeater,  :date],
          [:datetime,       "Date and Time"                                   , true,  :none, "default", :repeater,  :datetime],
          [:time,           "Time"                                            , true,  :none, "default", :repeater,  :time],
          [:slider,         "Slider"                                          , true,  :one,  :slider,   :repeater,  :all],
          [:stars,          "1-5 Stars"                                       , true,  :one,  :stars,    :repeater,  :all],
          [:label,          "Label"                                           , true,  :none, :label,    :repeater,  :all],
          [:file,           "File Upload"                                     , true,  :none, "default", :repeater,  :blob],

          [:string,         "Text"                                            , true,  :none, :default,  :grid,    :all],
          #surveyor seems to have an inline option that doesn't actually render inline yet.  Recognize it
          #but don't treat it differently.  See question 16 and 17 in kitchen_sink_survey.rb.
          [:pick_one,       "Multiple Choice (only one answer)"               , true,  :one,  "inline",  nil,      :answer],
          [:pick_any,       "Multiple Choice (multiple answers)"              , true,  :any,  "inline",  nil,      :answer],
          [:pick_one,       "Multiple Choice (only one answer)"               , false, :one,  "inline",  nil,      :answer],
          [:pick_any,       "Multiple Choice (multiple answers)"              , false, :any,  "inline",  nil,      :answer]
        ]


        def categorize_question(question)
          question_group_display_type = question.part_of_group? ? question.question_group.display_type : ""
          answer = question.answers.first
          all.each do |question_type|
            return question_type.id if _match_found(question, question_type, question_group_display_type, answer)
          end
          raise "No question_type matches question #{question.id}" unless Rails.env.test?
        end

        def all
          arr = []
          type = Struct.new(:id, :text, :part_of_group, :pick, :display_type, :group_display_type, :response_class)
          AllTypes.each do |t|
            arr << QuestionType.new(id:                 t[0],
                                    text:               t[1],
                                    part_of_group:      t[2],
                                    pick:               t[3],
                                    display_type:       t[4],
                                    group_display_type: t[5],
                                    response_class:     t[6]
            )
          end
          arr
        end

        def find(id)
          all.select{|qt| qt.id == id}[0]
        end

        private

        def _match_found(question, question_type, question_group_display_type, answer)
          answer_response_class = answer ? answer.response_class : "string"

          _match(question.part_of_group?,     question_type.part_of_group, :part_of_group)          &&
            _match(question.pick,               question_type.pick.to_s, :pick)                       &&
            _match(question.display_type.to_s,  question_type.display_type.to_s, :display_type)       &&
            _match(question_group_display_type, question_type.group_display_type.to_s, :group_display_type)  &&
            _match(answer_response_class,       question_type.response_class.to_s, :response_class)
        end

        def _match(question_attribute, question_type_attribute, match_attribute)
          (question_attribute == question_type_attribute) ||
            (question_type_attribute == "all")
        end
      end
    end

  end
end

class TextBoxParser
  include Enumerable
  def initialize(args)
    @text = args[:textbox].to_s.gsub("\r","")
    @nested_objects = args[:records_to_update]
    @starting_display_order = args.fetch(:starting_display_order,0)
  end

  def each(&block)
    _lines.readlines.each(&block)
  end

  def update_or_create_records(update_params={}, &create_object)
    #takes a code block to customize creation of new objects
    #update and delete operations are always the same.  For now.
    _lines.readlines.each_with_index do |line, display_order|
      _update_or_create(
        line.strip,
        display_order + @starting_display_order,
        update_params,
        &create_object
      ) unless line.blank?
    end
    _delete_orphans
  end

  private

  def _lines
    StringIO.new(@text)
  end

  def _update_or_create(text, display_order, update_params={}, &create_object)
    nested_objects = _find_nested_if_exists(text)
    if nested_objects.empty?
      create_object.call(display_order, text)
    else
      _update_nested_object(nested_objects.first, display_order, update_params)
    end
  end

  def _delete_orphans
    valid_rows = @text.split("\n")
    valid_rows = valid_rows.map{|vr| vr.strip}
    @nested_objects.reload
    @nested_objects.each do |nested_object|
      #puts "possibly deleting #{nested_object.class.name} #{nested_object.id} #{nested_object.text.rstrip} valid #{valid_rows}"
      nested_object.destroy unless valid_rows.include? "#{nested_object.text.rstrip}"
    end
    _dedupe
  end

  def _find_nested_if_exists(text)
    @nested_objects.where('text = ?',text)
  end

  def _update_nested_object(nested_object, index, update_params)
    params = {:display_order=>index}.merge(update_params)
    nested_object.update(params)
  end

  def _dedupe
    grouped = @nested_objects.order('display_order DESC').distinct{|n| n.id}.collect(&:id)
    @nested_objects.each do |obj|
      obj.destroy if (!grouped.include?(obj.id) && obj.persisted?)
    end
  end

end
