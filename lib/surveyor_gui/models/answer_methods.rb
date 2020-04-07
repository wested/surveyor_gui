module SurveyorGui
  module Models
    module AnswerMethods

      def self.included(base)
        base.send :belongs_to, :question
        base.send :has_many, :responses
        base.send :belongs_to, :column
        base.send :default_scope, lambda { base.order('display_order') }
        base.send :attr_accessible, :text, :response_class, :display_order, :original_choice, :hide_label, :question_id,
                  :display_type, :is_comment, :column if defined? ActiveModel::MassAssignmentSecurity
        base.send :scope, :is_not_comment, -> { base.where(is_comment: false) }
        base.send :scope, :is_comment, -> { base.where(is_comment: true) }

        base.send :validates_numericality_of, :weight, allow_blank: true
      end

      def split_or_hidden_text(part = nil)
        #return "" if hide_label.to_s == "true"
        return "" if display_type.to_s == "hidden_label"
        part == :pre ? text.split("|",2)[0] : (part == :post ? text.split("|",2)[1] : text)
      end

      private

      # Overriding Surveyor method so we can add an image class for styling.
      def imaged(text)
        self.display_type == "image" && !text.blank? ? ActionController::Base.helpers.image_tag(text, class: "image-answer") : text
      end
    end
  end
end
