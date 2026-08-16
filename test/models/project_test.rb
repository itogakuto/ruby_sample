require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "is valid with a name" do
    project = Project.new(name: "新規プロジェクト")

    assert project.valid?
  end

  test "requires a name" do
    project = Project.new(name: "")

    assert_not project.valid?
    assert project.errors.of_kind?(:name, :blank)
  end

  test "destroying a project destroys its sprints" do
    project = projects(:one)
    sprint_id = sprints(:one).id

    project.destroy!

    assert_not Sprint.exists?(sprint_id)
  end
end
