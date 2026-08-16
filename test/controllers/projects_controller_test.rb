require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "index renders project cards" do
    get projects_url

    assert_response :success
    assert_select ".project-card", Project.count
  end

  test "index orders projects by most recently updated" do
    older_project = projects(:one)
    newer_project = projects(:two)
    older_project.update_column(:updated_at, 2.days.ago)
    newer_project.update_column(:updated_at, 1.day.ago)

    get projects_url

    names = css_select(".project-card h2 a").map { |link| link.text.strip }
    assert_equal [ newer_project.name, older_project.name ], names
  end

  test "index renders an empty state without projects" do
    Sprint.delete_all
    Project.delete_all

    get projects_url

    assert_response :success
    assert_select ".project-card", count: 0
    assert_select ".empty-state", text: /最初のプロジェクトを作りましょう/
  end

  test "new renders the project form" do
    get new_project_url

    assert_response :success
    assert_select "form.form-card"
    assert_select "label[for='project_name']", text: /プロジェクト名/
    assert_select "input[name='project[name]']"
  end

  test "create saves a project and shows a notice" do
    assert_difference("Project.count", 1) do
      post projects_url, params: {
        project: {
          name: "検索体験改善",
          description: "必要な情報へ早く到達できるようにする"
        }
      }
    end

    project = Project.order(:id).last
    assert_equal "検索体験改善", project.name
    assert_equal "必要な情報へ早く到達できるようにする", project.description
    assert_redirected_to project_path(project)

    follow_redirect!
    assert_select ".flash--notice", text: "プロジェクトを作成しました。"
  end

  test "create rejects a project without a name" do
    assert_no_difference("Project.count") do
      post projects_url, params: {
        project: { name: "", description: "名前のないプロジェクト" }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".error-summary", text: /入力内容を確認してください/
    assert_select "input[name='project[name]'][value='']"
  end

  test "edit renders the project form" do
    project = projects(:one)

    get edit_project_url(project)

    assert_response :success
    assert_select "form.form-card"
    assert_select "input[name='project[name]']" do |inputs|
      assert_equal project.name, inputs.first["value"]
    end
  end

  test "update changes a project and shows a notice" do
    project = projects(:one)

    patch project_url(project), params: {
      project: {
        name: "更新後のプロジェクト",
        description: "更新された説明"
      }
    }

    assert_redirected_to project_path(project)
    assert_equal "更新後のプロジェクト", project.reload.name
    assert_equal "更新された説明", project.description

    follow_redirect!
    assert_select ".flash--notice", text: "プロジェクトを更新しました。"
  end

  test "update rejects a blank name" do
    project = projects(:one)
    original_name = project.name

    patch project_url(project), params: {
      project: { name: "", description: "更新されない説明" }
    }

    assert_response :unprocessable_entity
    assert_equal original_name, project.reload.name
    assert_select ".error-summary", text: /入力内容を確認してください/
  end

  test "show links to the edit page and does not use the Turbo cache" do
    project = projects(:one)

    get project_url(project)

    assert_response :success
    assert_select "a[href=?]", edit_project_path(project), text: "編集"
    assert_select ".sprint-card"
    assert_select "meta[name='turbo-cache-control'][content='no-cache']", visible: false
    assert_select "meta[name='history-resource-check'][content='true']", visible: false
    assert_select "meta[name='history-resource-fallback'][content=?]", projects_path, visible: false
  end

  test "show renders an empty state without sprints" do
    project = Project.create!(name: "Sprintのないプロジェクト")

    get project_url(project)

    assert_response :success
    assert_select ".sprint-card", count: 0
    assert_select ".empty-state", text: /最初のSprintを始めましょう/
  end

  test "destroy removes the project and its sprints and shows a notice" do
    project = projects(:one)

    assert_difference([ "Project.count", "Sprint.count" ], -1) do
      delete project_url(project)
    end

    assert_redirected_to projects_path
    follow_redirect!
    assert_select ".flash--notice", text: "プロジェクトを削除しました。"
  end

  test "deleted project URL redirects to the index with an alert" do
    project = projects(:one)
    project.destroy!

    get project_url(project)

    assert_redirected_to projects_path
    follow_redirect!
    assert_select ".flash--alert[role='alert']", text: "このプロジェクトは削除されているため表示できません。"
  end

  test "history resource check returns not found for a deleted project" do
    project = projects(:one)
    project.destroy!

    head project_url(project), headers: { "X-History-Resource-Check" => "true" }

    assert_response :not_found
  end

  test "missing project edit update and destroy redirect safely" do
    missing_id = 0

    get edit_project_url(missing_id)
    assert_redirected_to projects_path

    patch project_url(missing_id), params: { project: { name: "存在しない" } }
    assert_redirected_to projects_path

    delete project_url(missing_id)
    assert_redirected_to projects_path
  end
end
