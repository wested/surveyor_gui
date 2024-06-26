require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dependency do
  before(:each) do
    @dependency = FactoryBot.create(:dependency)
  end

  it "should be valid" do
    expect(@dependency).to be_valid
  end

  it "should be invalid without a rule" do
    @dependency.rule = nil
    @dependency.valid?
    expect(@dependency.errors[:rule].size).to eq(2)

    @dependency.rule = " "
    @dependency.valid?
    expect(@dependency.errors[:rule].size).to eq(1)
  end

  it "should be invalid without a question_id" do
    @dependency.question_id = nil
    @dependency.valid?
    expect(@dependency.errors[:question_id].size).to eq(1)

    @dependency.question_group_id = 1
    expect(@dependency).to be_valid

    expect(@dependency.question_id).to be_nil
    @dependency.question_group_id = nil
    @dependency.valid?
    expect(@dependency.errors[:question_group_id].size).to eq(1)
  end

  it "should alias question_id as dependent_question_id" do
    @dependency.question_id = 19
    expect(@dependency.dependent_question_id).to eq(19)
    @dependency.dependent_question_id = 14
    expect(@dependency.question_id).to eq(14)
  end

  it "should be invalid unless rule composed of only references and operators" do
    @dependency.rule = "foo"
    @dependency.valid?
    expect(@dependency.errors[:rule].size).to eq(1)

    @dependency.rule = "1 to 2"
    @dependency.valid?
    expect(@dependency.errors[:rule].size).to eq(1)

    @dependency.rule = "a and b"
    @dependency.valid?
    expect(@dependency.errors[:rule].size).to eq(1)
  end
end

describe Dependency, "when evaluating dependency conditions of a question in a response set" do

  before(:each) do
    @dep = Dependency.new(:rule => "A", :question_id => 1)
    @dep2 = Dependency.new(:rule => "A and B", :question_id => 1)
    @dep3 = Dependency.new(:rule => "A or B", :question_id => 1)
    @dep4 = Dependency.new(:rule => "!(A and B) and C", :question_id => 1)

    @dep_c = double(DependencyCondition, :id => 1, :rule_key => "A", :to_hash => {:A => true})
    @dep_c2 = double(DependencyCondition, :id => 2, :rule_key => "B", :to_hash => {:B => false})
    @dep_c3 = double(DependencyCondition, :id => 3, :rule_key => "C", :to_hash => {:C => true})

    allow(@dep).to receive(:dependency_conditions).and_return([@dep_c])
    allow(@dep2).to receive(:dependency_conditions).and_return([@dep_c, @dep_c2])
    allow(@dep3).to receive(:dependency_conditions).and_return([@dep_c, @dep_c2])
    allow(@dep4).to receive(:dependency_conditions).and_return([@dep_c, @dep_c2, @dep_c3])
  end

  it "knows if the dependencies are met" do
    expect(@dep.is_met?(@response_set)).to be_truthy
    expect(@dep2.is_met?(@response_set)).to be_falsey
    expect(@dep3.is_met?(@response_set)).to be_truthy
    expect(@dep4.is_met?(@response_set)).to be_truthy
  end

  it "returns the proper keyed pairs from the dependency conditions" do
    expect(@dep.conditions_hash(@response_set)).to eq({:A => true})
    expect(@dep2.conditions_hash(@response_set)).to eq({:A => true, :B => false})
    expect(@dep3.conditions_hash(@response_set)).to eq({:A => true, :B => false})
    expect(@dep4.conditions_hash(@response_set)).to eq({:A => true, :B => false, :C => true})
  end
end
describe Dependency, "with conditions" do
  it "should destroy conditions when destroyed" do
    @dependency = Dependency.new(:rule => "A and B and C", :question_id => 1)
    FactoryBot.create(:dependency_condition, :dependency => @dependency, :rule_key => "A")
    FactoryBot.create(:dependency_condition, :dependency => @dependency, :rule_key => "B")
    FactoryBot.create(:dependency_condition, :dependency => @dependency, :rule_key => "C")
    dc_ids = @dependency.dependency_conditions.map(&:id)
    @dependency.destroy
    dc_ids.each{|id| expect(DependencyCondition.find_by_id(id)).to eq(nil)}
  end
end
