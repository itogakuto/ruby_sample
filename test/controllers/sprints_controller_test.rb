require "test_helper"

class SprintsControllerTest < ActionDispatch::IntegrationTest
  test "creates a sprint with a customer value hypothesis" do
    project = projects(:one)

    assert_difference("Sprint.count", 1) do
      post project_sprints_url(project), params: {
        sprint: {
          customer_value_hypothesis: "利用者は一覧画面で優先順位を確認したい",
          validation_method: "5人にインタビューする",
          validation_result: "",
          learning: "",
          next_action: ""
        }
      }
    end

    assert_equal "利用者は一覧画面で優先順位を確認したい", Sprint.order(:created_at).last.customer_value_hypothesis
  end

  test "updates a sprint" do
    project = projects(:one)
    sprint = sprints(:one)

    patch project_sprint_url(project, sprint), params: {
      sprint: { learning: "入力項目は少ない方が使いやすい" }
    }

    assert_redirected_to project_sprint_path(project, sprint)
    assert_equal "入力項目は少ない方が使いやすい", sprint.reload.learning
  end

  test "index links each sprint to its detail page" do
    project = projects(:one)
    sprint = sprints(:one)

    get project_sprints_url(project)

    assert_response :success
    assert_select "a[href=?]", project_sprint_path(project, sprint), text: sprint.customer_value_hypothesis
  end
end
