# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Survey do
  let(:survey){ FactoryBot.create(:survey) }

  context "when creating" do
    it "is invalid without #title" do
      survey.title = nil
      survey.valid?
      expect(survey.errors[:title].size).to eq(1)
    end
    it "adjust #survey_version" do
      original = Survey.new(:title => "Foo")
      expect(original.save).to be_truthy
      expect(original.survey_version).to eq(0)
      imposter = Survey.new(:title => "Foo")
      expect(imposter.save).to be_truthy
      expect(imposter.title).to eq("Foo")
      expect(imposter.survey_version).to eq(1)
      bandwagoneer = Survey.new(:title => "Foo")
      expect(bandwagoneer.save).to be_truthy
      expect(bandwagoneer.title).to eq("Foo")
      expect(bandwagoneer.survey_version).to eq(2)
    end
    it "prevents duplicate #survey_version" do
      original = Survey.new(:title => "Foo")
      expect(original.save).to be_truthy
      imposter = Survey.new(:title => "Foo")
      expect(imposter.save).to be_truthy
      imposter.survey_version = 0
      expect(imposter.save).to be_falsey
      imposter.valid?
      expect(imposter.errors[:survey_version].size).to eq(1)
    end
    it "doesn't adjust #title when" do
      original = FactoryBot.create(:survey, :title => "Foo")
      expect(original.save).to be_truthy
      original.update(:title => "Foo")
      expect(original.title).to eq("Foo")
    end
    it "has #api_id with 36 characters by default" do
      expect(survey.api_id.length).to eq(36)
    end
  end

  context "activating" do
    it "both #inactive_at and #active_at == nil by default" do
      expect(survey.active_at).to be_nil
      expect(survey.inactive_at).to be_nil
    end
    it "#active_at on a certain date/time" do
      survey.inactive_at = 2.days.from_now
      survey.active_at = 2.days.ago
      expect(survey.active?).to be_truthy
    end
    it "#inactive_at on a certain date/time" do
      survey.active_at = 3.days.ago
      survey.inactive_at = 1.days.ago
      expect(survey.active?).to be_falsey
    end
    it "#activate! and #deactivate!" do
      survey.activate!
      expect(survey.active?).to be_truthy
      survey.deactivate!
      expect(survey.active?).to be_falsey
    end
    it "nils out past values of #inactive_at on #activate!" do
      survey.inactive_at = 5.days.ago
      expect(survey.active?).to be_falsey
      survey.activate!
      expect(survey.active?).to be_truthy
      expect(survey.inactive_at).to be_nil
    end
    it "nils out pas values of #active_at on #deactivate!" do
      survey.active_at = 5.days.ago
      expect(survey.active?).to be_truthy
      survey.deactivate!
      expect(survey.active?).to be_falsey
      expect(survey.active_at).to be_nil
    end
  end

  context "with survey_sections" do
    let(:s1){ FactoryBot.create(:survey_section, :survey => survey, :title => "wise", :display_order => 2)}
    let(:s2){ FactoryBot.create(:survey_section, :survey => survey, :title => "er", :display_order => 3)}
    let(:s3){ FactoryBot.create(:survey_section, :survey => survey, :title => "bud", :display_order => 1)}
    let(:q1){ FactoryBot.create(:question, :survey_section => s1, :text => "what is wise?", :display_order => 2)}
    let(:q2){ FactoryBot.create(:question, :survey_section => s2, :text => "what is er?", :display_order => 4)}
    let(:q3){ FactoryBot.create(:question, :survey_section => s2, :text => "what is mill?", :display_order => 3)}
    let(:q4){ FactoryBot.create(:question, :survey_section => s3, :text => "what is bud?", :display_order => 1)}
    before do
      [s1, s2, s3].each{|s| survey.sections << s }
      s1.questions << q1
      s2.questions << q2
      s2.questions << q3
      s3.questions << q4
    end

    it{ expect(survey.sections.size).to eq(3)}
    it "gets survey_sections in order" do
      expect(survey.sections.order("display_order asc")).to eq([s3, s1, s2])
      expect(survey.sections.order("display_order asc").map(&:display_order)).to eq([1,2,3])
    end
    it "gets survey_sections_with_questions in order" do
      expect(survey.sections.order("display_order asc").map{|ss| ss.questions.order("display_order asc")}.flatten.size).to eq(4)
      expect(survey.sections.order("display_order asc").map{|ss| ss.questions.order("display_order asc")}.flatten).to eq([q4,q1,q3,q2])
    end
    it "deletes child survey_sections when deleted" do
      survey_section_ids = survey.sections.map(&:id)
      survey.destroy
      survey_section_ids.each{|id| expect(SurveySection.find_by_id(id)).to be_nil}
    end
  end

  context "serialization" do
    let(:s1){ FactoryBot.create(:survey_section, :survey => survey, :title => "wise") }
    let(:s2){ FactoryBot.create(:survey_section, :survey => survey, :title => "er") }
    let(:q1){ FactoryBot.create(:question, :survey_section => s1, :text => "what is wise?") }
    let(:q2){ FactoryBot.create(:question, :survey_section => s2, :text => "what is er?") }
    let(:q3){ FactoryBot.create(:question, :survey_section => s2, :text => "what is mill?") }
    before do
      [s1, s2].each{|s| survey.sections << s }
      s1.questions << q1
      s2.questions << q2
      s2.questions << q3
    end

    it "includes title, sections, and questions" do
      actual = survey.as_json
      expect(actual[:title]).to eq('Simple survey')
      expect(actual[:sections].size).to eq(2)
      expect(actual[:sections][0][:questions_and_groups].size).to eq(1)
      expect(actual[:sections][1][:questions_and_groups].size).to eq(2)
    end
  end

  context "with translations" do
    require 'yaml'
    let(:survey_translation){
      FactoryBot.create(:survey_translation, :locale => :es, :translation => {
        :title => "Un idioma nunca es suficiente"
      }.to_yaml)
    }
    before do
      survey.translations << survey_translation
    end
    it "returns its own translation" do
      expect(YAML.load(survey_translation.translation)).not_to be_nil
      expect(survey.translation(:es)[:title]).to eq("Un idioma nunca es suficiente")
    end
    it "returns its own default values" do
      expect(survey.translation(:de)).to eq({"title" => survey.title, "description" => survey.description})
    end
  end
end
