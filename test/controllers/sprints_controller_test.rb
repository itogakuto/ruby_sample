require "test_helper"

class SprintsControllerTest < ActionDispatch::IntegrationTest
  test "new renders the five-step sprint form" do
    project = projects(:one)

    get new_project_sprint_url(project)

    assert_response :success
    assert_select "form.sprint-form"
    assert_select ".form-step", 5
  end

  test "edit renders the five-step sprint form" do
    project = projects(:one)
    sprint = sprints(:one)

    get edit_project_sprint_url(project, sprint)

    assert_response :success
    assert_select "form.sprint-form"
    assert_select ".form-step", 5
  end

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

  test "show renders all canvas sections" do
    project = projects(:one)
    sprint = sprints(:one)

    get project_sprint_url(project, sprint)

    assert_response :success
    assert_select ".canvas-card", 5
    assert_select "h2", text: "顧客価値仮説"
    assert_select "h2", text: "次アクション"
    assert_select "meta[name='turbo-cache-control'][content='no-cache']", visible: false
  end

  test "deleted sprint URL redirects to the sprint index with an alert" do
    project = projects(:one)
    sprint = sprints(:one)
    sprint.destroy!

    get project_sprint_url(project, sprint)

    assert_redirected_to project_sprints_path(project)
    follow_redirect!
    assert_select ".flash--alert[role='alert']", text: "このSprintは削除されているため表示できません。"
  end

  test "sprint URL under a deleted project redirects to projects with an alert" do
    project = projects(:one)
    sprint = sprints(:one)
    project.destroy!

    get project_sprint_url(project, sprint)

    assert_redirected_to projects_path
    follow_redirect!
    assert_select ".flash--alert[role='alert']", text: "このプロジェクトは削除されているため表示できません。"
  end
end
