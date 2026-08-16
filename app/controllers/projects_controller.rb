class ProjectsController < ApplicationController
    def index
        @projects = Project.includes(:sprints).order(updated_at: :desc)
    end

    def new
        @project = Project.new
    end

    def create
        @project = Project.new(project_params)

        if @project.save
            redirect_to @project, notice: "プロジェクトを作成しました。"
        else
            render :new, status: :unprocessable_entity
        end
    end

    def show
        @project = Project.find(params[:id])
        @sprints = @project.sprints.order(created_at: :desc)
        @latest_activity = [ @project.updated_at, @sprints.first&.updated_at ].compact.max
    end

    def edit
        @project = Project.find(params[:id])
    end

    def update
        @project = Project.find(params[:id])

        if @project.update(project_params)
            redirect_to @project, notice: "プロジェクトを更新しました。"
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @project = Project.find(params[:id])
        @project.destroy

        redirect_to projects_path, notice: "プロジェクトを削除しました。"
    end

    private

    def project_params
        params.require(:project).permit(:name, :description)
    end
end
