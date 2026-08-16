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
  end

  test "destroy removes the project and its sprints" do
    project = projects(:one)

    assert_difference([ "Project.count", "Sprint.count" ], -1) do
      delete project_url(project)
    end

    assert_redirected_to projects_path
  end
end
