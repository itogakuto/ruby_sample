class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_from_deleted_resource

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def redirect_from_deleted_resource
    return head :not_found if history_resource_check?

    if controller_name == "sprints"
      redirect_from_deleted_sprint
    elsif controller_name == "projects"
      redirect_to projects_path, alert: "このプロジェクトは削除されているため表示できません。"
    else
      redirect_to root_path, alert: "指定されたページは存在しません。"
    end
  end

  def redirect_from_deleted_sprint
    project = Project.find_by(id: params[:project_id])

    if project
      redirect_to project_sprints_path(project), alert: "このSprintは削除されているため表示できません。"
    else
      redirect_to projects_path, alert: "このプロジェクトは削除されているため表示できません。"
    end
  end

  def history_resource_check?
    request.head? && request.headers["X-History-Resource-Check"] == "true"
  end
end
