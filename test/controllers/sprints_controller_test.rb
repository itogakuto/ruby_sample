require "test_helper"

class SprintsControllerTest < ActionDispatch::IntegrationTest
  test "new renders the five-step sprint form" do
    project = projects(:one)

    get new_project_sprint_url(project)

    assert_response :success
    assert_select "form.sprint-form"
    assert_select ".form-step", 5
    %w[customer_value_hypothesis validation_method validation_result learning next_action].each do |field|
      assert_select "textarea[name='sprint[#{field}]']"
    end
  end

  test "edit renders the five-step sprint form" do
    project = projects(:one)
    sprint = sprints(:one)

    get edit_project_sprint_url(project, sprint)

    assert_response :success
    assert_select "form.sprint-form"
    assert_select ".form-step", 5
    assert_select "textarea[name='sprint[customer_value_hypothesis]']", text: sprint.customer_value_hypothesis
  end

  test "create saves all canvas fields under the URL project and shows a notice" do
    project = projects(:one)
    other_project = projects(:two)
    attributes = {
      customer_value_hypothesis: "利用者は一覧画面で優先順位を確認したい",
      validation_method: "5名にインタビューする",
      validation_result: "4名が優先順位を確認できた",
      learning: "並び順の根拠も必要だった",
      next_action: "根拠を表示した一覧を再検証する",
      project_id: other_project.id
    }

    assert_difference("Sprint.count", 1) do
      post project_sprints_url(project), params: { sprint: attributes }
    end

    sprint = Sprint.order(:id).last
    expected_attributes = attributes.except(:project_id).stringify_keys
    assert_equal project, sprint.project
    assert_equal expected_attributes, sprint.attributes.slice(*expected_attributes.keys)
    assert_redirected_to project_sprint_path(project, sprint)

    follow_redirect!
    assert_select ".flash--notice", text: "Sprintを作成しました。"
  end

  test "update changes all canvas fields but cannot move the sprint to another project" do
    project = projects(:one)
    sprint = sprints(:one)
    other_project = projects(:two)
    attributes = {
      customer_value_hypothesis: "更新した顧客価値仮説",
      validation_method: "更新した検証方法",
      validation_result: "更新した検証結果",
      learning: "更新した学び",
      next_action: "更新した次アクション",
      project_id: other_project.id
    }

    patch project_sprint_url(project, sprint), params: { sprint: attributes }

    assert_redirected_to project_sprint_path(project, sprint)
    sprint.reload
    expected_attributes = attributes.except(:project_id).stringify_keys
    assert_equal project, sprint.project
    assert_equal expected_attributes, sprint.attributes.slice(*expected_attributes.keys)

    follow_redirect!
    assert_select ".flash--notice", text: "Sprintを更新しました。"
  end

  test "destroy removes a sprint and shows a notice" do
    project = projects(:one)
    sprint = sprints(:one)

    assert_difference("Sprint.count", -1) do
      delete project_sprint_url(project, sprint)
    end

    assert_redirected_to project_sprints_path(project)
    follow_redirect!
    assert_select ".flash--notice", text: "Sprintを削除しました。"
  end

  test "index links each sprint to its detail page" do
    project = projects(:one)
    sprint = sprints(:one)

    get project_sprints_url(project)

    assert_response :success
    assert_select "a[href=?]", project_sprint_path(project, sprint), text: sprint.customer_value_hypothesis
  end

  test "index orders sprints by most recently created" do
    project = projects(:one)
    older_sprint = sprints(:one)
    newer_sprint = project.sprints.create!(customer_value_hypothesis: "新しいSprint")
    older_sprint.update_column(:created_at, 2.days.ago)
    newer_sprint.update_column(:created_at, 1.day.ago)

    get project_sprints_url(project)

    hypotheses = css_select(".sprint-card h2 a").map { |link| link.text.strip }
    assert_equal [ newer_sprint.customer_value_hypothesis, older_sprint.customer_value_hypothesis ], hypotheses
  end

  test "index renders an empty state without sprints" do
    project = Project.create!(name: "Sprintのないプロジェクト")

    get project_sprints_url(project)

    assert_response :success
    assert_select ".sprint-card", count: 0
    assert_select ".empty-state", text: /まだSprintがありません/
  end

  test "show renders all canvas sections without using the Turbo cache" do
    project = projects(:one)
    sprint = sprints(:one)

    get project_sprint_url(project, sprint)

    assert_response :success
    assert_select ".canvas-card", 5
    assert_select "h2", text: "顧客価値仮説"
    assert_select "h2", text: "次アクション"
    assert_select ".canvas-card", text: /#{Regexp.escape(sprint.customer_value_hypothesis)}/
    assert_select "meta[name='turbo-cache-control'][content='no-cache']", visible: false
    assert_select "meta[name='history-resource-check'][content='true']", visible: false
    assert_select "meta[name='history-resource-fallback'][content=?]", project_sprints_path(project), visible: false
  end

  test "show escapes HTML entered in a canvas field" do
    project = projects(:one)
    sprint = sprints(:one)
    sprint.update!(customer_value_hypothesis: "<script>alert('危険')</script>")

    get project_sprint_url(project, sprint)

    assert_response :success
    assert_select ".canvas-card script", count: 0
    assert_select ".canvas-card", text: /alert\('危険'\)/
  end

  test "a sprint cannot be accessed through a different project" do
    project = projects(:one)
    other_project_sprint = sprints(:two)

    get project_sprint_url(project, other_project_sprint)

    assert_redirected_to project_sprints_path(project)
    follow_redirect!
    assert_select ".flash--alert[role='alert']", text: "このSprintは削除されているため表示できません。"
  end

  test "history resource check returns not found for a deleted sprint" do
    project = projects(:one)
    sprint = sprints(:one)
    sprint.destroy!

    head project_sprint_url(project, sprint), headers: { "X-History-Resource-Check" => "true" }

    assert_response :not_found
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

  test "missing sprint edit update and destroy redirect safely" do
    project = projects(:one)
    missing_id = 0

    get edit_project_sprint_url(project, missing_id)
    assert_redirected_to project_sprints_path(project)

    patch project_sprint_url(project, missing_id), params: { sprint: { learning: "存在しない" } }
    assert_redirected_to project_sprints_path(project)

    delete project_sprint_url(project, missing_id)
    assert_redirected_to project_sprints_path(project)
  end

  test "missing parent project redirects safely" do
    get project_sprints_url(0)

    assert_redirected_to projects_path
    follow_redirect!
    assert_select ".flash--alert[role='alert']", text: "このプロジェクトは削除されているため表示できません。"
  end
end
