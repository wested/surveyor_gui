module SurveyorGui
  module Models
    module ResponseSetMethods

      def self.included(base)
        base.send :has_many, :responses, :dependent=>:destroy
        base.send :has_many, :answers, through: :responses, :source=>"answer"

        base.send :attr_accessible, :survey, :responses_attributes, :user_id, :survey_id, :test_data if defined? ActiveModel::MassAssignmentSecurity
      end

      def report_user_name
        user_name = nil
        fake_users = {'0'=>'Bob', '-1'=>'Kishore','-2'=>'Tina','-3'=>'Xiao','-4'=>'Marshal','-5'=>'Lana','-6'=>'Demarius','-7'=>'Taylor','-8'=>'Cameron','-9'=>'Clio'}
        if class_exists?('ResponseSetUser')
          user_name = ResponseSetUser.new(self.user_id).report_user_name
        end
        user_name || fake_users[self.user_id.to_s] || self.id
      end

      private

      def class_exists?(class_name)
        klass = Module.const_get(class_name)
        return klass.is_a?(Class)
      rescue NameError
        return false
      end
    end
  end
end
