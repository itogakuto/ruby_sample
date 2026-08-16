require "test_helper"

class SprintTest < ActiveSupport::TestCase
  test "is valid when it belongs to a project" do
    sprint = Sprint.new(project: projects(:one))

    assert sprint.valid?
  end

  test "requires a project" do
    sprint = Sprint.new(project: nil)

    assert_not sprint.valid?
    assert sprint.errors.of_kind?(:project, :blank)
  end

  test "preserves multiline text and special characters" do
    hypothesis = "利用者は比較したい\nただし <候補> は3件まで"
    sprint = projects(:one).sprints.create!(customer_value_hypothesis: hypothesis)

    assert_equal hypothesis, sprint.reload.customer_value_hypothesis
  end
end
