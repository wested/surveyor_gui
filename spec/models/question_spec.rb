# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Question do
  let(:question){ FactoryBot.create(:question) }

  context "when creating" do
    it "is invalid without #text" do
      question.text = nil
      question.valid?
      expect(question.errors[:text].size).to eq(1)
    end
    it "#is_mandantory == false by default" do
      expect(question.mandatory?).to be_falsey
    end
    it "converts #pick to string" do
      expect(question.pick).to eq("none")
      question.pick = :one
      expect(question.pick).to eq("one")
      question.pick = nil
      expect(question.pick).to eq(nil)
    end
    it "#renderer == 'default' when #display_type = nil" do
      question.display_type = nil
      expect(question.renderer).to eq(:default)
    end
    it "has #api_id with 36 characters by default" do
      expect(question.api_id.length).to eq(36)
    end
    it "#part_of_group? and #solo? are aware of question groups" do
      question.question_group = FactoryBot.create(:question_group)
      expect(question.solo?).to be_falsey
      expect(question.part_of_group?).to be_truthy

      question.question_group = nil
      expect(question.solo?).to be_truthy
      expect(question.part_of_group?).to be_falsey
    end
  end

  context "with answers" do
    let(:answer_1){ FactoryBot.create(:answer, :question => question, :display_order => 3, :text => "blue")}
    let(:answer_2){ FactoryBot.create(:answer, :question => question, :display_order => 1, :text => "red")}
    let(:answer_3){ FactoryBot.create(:answer, :question => question, :display_order => 2, :text => "green")}
    before do
      [answer_1, answer_2, answer_3].each{|a| question.answers << a }
    end
    it{ expect(question.answers.size).to eq(3)}
    it "gets answers in order" do
      expect(question.answers.order("display_order asc")).to eq([answer_2, answer_3, answer_1])
      expect(question.answers.order("display_order asc").map(&:display_order)).to eq([1,2,3])
    end
    it "deletes child answers when deleted" do
      answer_ids = question.answers.map(&:id)
      question.destroy
      answer_ids.each{|id| expect(Answer.find_by_id(id)).to be_nil}
    end
  end

  context "with dependencies" do
    let(:response_set){ FactoryBot.create(:response_set) }
    let(:dependency){ FactoryBot.create(:dependency) }
    before do
      question.dependency = dependency
      allow(dependency).to receive(:is_met?).with(response_set).and_return true
    end
    it "checks its dependency" do
      expect(question.triggered?(response_set)).to be_truthy
    end
    it "deletes its dependency when deleted" do
      d_id = question.dependency.id
      question.destroy
      expect(Dependency.find_by_id(d_id)).to be_nil
    end
  end

  context "with mustache text substitution" do
    require 'mustache'
    let(:mustache_context){ Class.new(::Mustache){ def site; "Northwestern"; end; def foo; "bar"; end } }
    it "subsitutes Mustache context variables" do
      question.text = "You are in {{site}}"
      expect(question.in_context(question.text, mustache_context)).to eq("You are in Northwestern")
    end
    it "substitues in views" do
      question.text = "You are in {{site}}"
      expect(question.text_for(nil, mustache_context)).to eq("You are in Northwestern")
    end
  end

  context "with translations" do
    require 'yaml'
    let(:survey){ FactoryBot.create(:survey) }
    let(:survey_section){ FactoryBot.create(:survey_section) }
    let(:survey_translation){
      FactoryBot.create(:survey_translation, :locale => :es, :translation => {
        :questions => {
          :hello => {
            :text => "¡Hola!"
          }
        }
      }.to_yaml)
    }
    before do
      question.reference_identifier = "hello"
      question.survey_section = survey_section
      survey_section.survey = survey
      survey.translations << survey_translation
    end
    it "returns its own translation" do
      expect(YAML.load(survey_translation.translation)).not_to be_nil
      expect(question.translation(:es)[:text]).to eq("¡Hola!")
    end
    it "returns its own default values" do
      expect(question.translation(:de)).to eq({"text" => question.text, "help_text" => question.help_text})
    end
    it "returns translations in views" do
      expect(question.text_for(nil, nil, :es)).to eq("¡Hola!")
    end
    it "returns default values in views" do
      expect(question.text_for(nil, nil, :de)).to eq(question.text)
    end
  end

  context "handling strings" do
    it "#split preserves strings" do
      expect(question.split(question.text)).to eq("What is your favorite color?")
    end
    it "#split(:pre) preserves strings" do
      expect(question.split(question.text, :pre)).to eq("What is your favorite color?")
    end
    it "#split(:post) preserves strings" do
      expect(question.split(question.text, :post)).to eq("")
    end
    it "#split splits strings" do
      question.text = "before|after|extra"
      expect(question.split(question.text)).to eq("before|after|extra")
    end
    it "#split(:pre) splits strings" do
      question.text = "before|after|extra"
      expect(question.split(question.text, :pre)).to eq("before")
    end
    it "#split(:post) splits strings" do
      question.text = "before|after|extra"
      expect(question.split(question.text, :post)).to eq("after|extra")
    end
  end

  context "for views" do
    it "#text_for with #display_type == image" do
      question.text = "/rails.png"
      question.display_type = :image
      expect(question.text_for).to eq '<img alt="Rails" src="/rails.png" />'
    end
    it "#help_text_for"
    it "#text_for preserves strings" do
      expect(question.text_for).to eq("What is your favorite color?")
    end
    it "#text_for(:pre) preserves strings" do
      expect(question.text_for(:pre)).to eq("What is your favorite color?")
    end
    it "#text_for(:post) preserves strings" do
      expect(question.text_for(:post)).to eq("")
    end
    it "#text_for splits strings" do
      question.text = "before|after|extra"
      expect(question.text_for).to eq("before|after|extra")
    end
    it "#text_for(:pre) splits strings" do
      question.text = "before|after|extra"
      expect(question.text_for(:pre)).to eq("before")
    end
    it "#text_for(:post) splits strings" do
      question.text = "before|after|extra"
      expect(question.text_for(:post)).to eq("after|extra")
    end
  end
end
