require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "show links to the edit page" do
    project = projects(:one)

    get project_url(project)

    assert_response :success
    assert_select "a[href=?]", edit_project_path(project), text: "Edit"
  end
end
