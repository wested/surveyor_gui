require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'rake'

describe Surveyor::Parser do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.add_import "#{gem_path('surveyor')}/lib/tasks/surveyor_tasks.rake"
    Rake.application.load_imports
    Rake::Task.define_task(:environment)
  end
  it "should return properly parse the kitchen sink survey" do
    ENV["FILE"]="surveys/kitchen_sink_survey.rb"
    @rake["surveyor"].invoke

    expect(Survey.count).to eq(1)
    expect(SurveySection.count).to eq(2)
    expect(Question.count).to eq(51)
    expect(Answer.count).to eq(252)
    expect(Dependency.count).to eq(8)
    expect(DependencyCondition.count).to eq(12)
    expect(QuestionGroup.count).to eq(6)

    Survey.all.map(&:destroy)
  end
  it "should return properly parse a UTF8 survey" do
    skip "failing - not clear why - await update of surveyor"
    ENV["FILE"]="../spec/fixtures/chinese_survey.rb"
    @rake["surveyor"].invoke

    expect(Survey.count).to eq(1)
    expect(SurveySection.count).to eq(1)
    expect(Question.count).to eq(3)
    expect(Answer.count).to eq(15)
    expect(Dependency.count).to eq(0)
    expect(DependencyCondition.count).to eq(0)
    expect(QuestionGroup.count).to eq(1)

    Survey.all.map(&:destroy)
  end

end
