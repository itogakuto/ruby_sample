require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "index renders project cards" do
    get projects_url

    assert_response :success
    assert_select ".project-card", Project.count
  end

  test "new renders the project form" do
    get new_project_url

    assert_response :success
    assert_select "form.form-card"
  end

  test "edit renders the project form" do
    get edit_project_url(projects(:one))

    assert_response :success
    assert_select "form.form-card"
  end

  test "show links to the edit page" do
    project = projects(:one)

    get project_url(project)

    assert_response :success
    assert_select "a[href=?]", edit_project_path(project), text: "編集"
    assert_select ".sprint-card"
    assert_select "meta[name='turbo-cache-control'][content='no-cache']", visible: false
  end

  test "destroy removes the project and its sprints" do
    project = projects(:one)

    assert_difference([ "Project.count", "Sprint.count" ], -1) do
      delete project_url(project)
    end

    assert_redirected_to projects_path
  end

  test "deleted project URL redirects to the index with an alert" do
    project = projects(:one)
    project.destroy!

    get project_url(project)

    assert_redirected_to projects_path
    follow_redirect!
    assert_select ".flash--alert[role='alert']", text: "このプロジェクトは削除されているため表示できません。"
  end
end
