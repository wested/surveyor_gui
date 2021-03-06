require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Validation do
  before(:each) do
    @validation = FactoryGirl.create(:validation)
  end

  it "should be valid" do
    expect(@validation).to be_valid
  end

  it "should be invalid without a rule" do
    @validation.rule = nil
    @validation.valid?
    expect(@validation.errors[:rule].size).to eq(2)

    @validation.rule = " "
    @validation.valid?
    expect(@validation.errors[:rule].size).to eq(1)
  end

  # this causes issues with building and saving
  # it "should be invalid without a answer_id" do
  #   @validation.answer_id = nil
  #   @validation.should have(1).error_on(:answer_id)
  # end

  it "should be invalid unless rule composed of only references and operators" do
    @validation.rule = "foo"
    @validation.valid?
    expect(@validation.errors[:rule].size).to eq(1)

    @validation.rule = "1 to 2"
    @validation.valid?
    expect(@validation.errors[:rule].size).to eq(1)

    @validation.rule = "a and b"
    @validation.valid?
    expect(@validation.errors[:rule].size).to eq(1)
  end
end
describe Validation, "reporting its status" do
  def test_var(vhash, vchashes, ahash, rhash)
    a = FactoryGirl.create(:answer, ahash)
    v = FactoryGirl.create(:validation, {:answer => a, :rule => "A"}.merge(vhash))
    vchashes.each do |vchash|
      FactoryGirl.create(:validation_condition, {:validation => v, :rule_key => "A"}.merge(vchash))
    end
    rs = FactoryGirl.create(:response_set)
    r = FactoryGirl.create(:response, {:answer => a, :question => a.question}.merge(rhash))
    rs.responses << r
    return v.is_valid?(rs)
  end

  it "should validate a response by integer comparison" do
    expect(test_var({:rule => "A and B"}, [{:operator => ">=", :integer_value => 0}, {:rule_key => "B", :operator => "<=", :integer_value => 120}], {:response_class => "integer"}, {:integer_value => 48})).to be_truthy
  end
  it "should validate a response by regexp" do
    expect(test_var({}, [{:operator => "=~", :regexp => '/^[a-z]{1,6}$/'}], {:response_class => "string"}, {:string_value => ""})).to be_falsey
  end
end
describe Validation, "with conditions" do
  it "should destroy conditions when destroyed" do
    @validation = FactoryGirl.create(:validation)
    FactoryGirl.create(:validation_condition, :validation => @validation, :rule_key => "A")
    FactoryGirl.create(:validation_condition, :validation => @validation, :rule_key => "B")
    FactoryGirl.create(:validation_condition, :validation => @validation, :rule_key => "C")
    v_ids = @validation.validation_conditions.map(&:id)
    @validation.destroy
    v_ids.each{|id| expect(DependencyCondition.find_by_id(id)).to eq(nil)}
  end
end