class SprintsController < ApplicationController
    before_action :set_project
    before_action :set_sprint, only: [ :show, :destroy, :update, :edit ]

    def index
        @sprints = @project.sprints.order(created_at: :desc)
    end

    def new
        @sprint = @project.sprints.new
    end

    def create
        @sprint = @project.sprints.new(sprint_params)

        if @sprint.save
            redirect_to project_sprint_path(@project, @sprint), notice: "Sprintを作成しました。"
        else
            render :new, status: :unprocessable_entity
        end
    end

    def show
    end

    def destroy
        @sprint.destroy
        redirect_to project_sprints_path(@project), notice: "Sprintを削除しました。"
    end

    def update
        if @sprint.update(sprint_params)
            redirect_to project_sprint_path(@project, @sprint), notice: "Sprintを更新しました。"
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def edit
    end

    private

    def set_project
        @project = Project.find(params[:project_id])
    end

    def set_sprint
        @sprint = @project.sprints.find(params[:id])
    end

    def sprint_params
        params.require(:sprint).permit(
            :customer_value_hypothesis,
            :validation_method,
            :validation_result,
            :learning,
            :next_action
        )
    end
end
