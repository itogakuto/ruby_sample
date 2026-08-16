require "application_system_test_case"

class OutcomeCanvasTest < ApplicationSystemTestCase
  test "a user can create and update a project and sprint" do
    visit root_path
    click_link "新しく始める"

    fill_in "プロジェクト名", with: "検索体験改善"
    fill_in "目的・概要", with: "必要な情報へ早く到達できる体験をつくる"
    click_button "プロジェクトを作成"

    assert_text "プロジェクトを作成しました。"
    assert_text "検索体験改善"
    click_link "＋ Sprintを作成"

    fill_in "顧客価値仮説", with: "利用者は比較軸が明確なら候補を選べる"
    fill_in "検証方法", with: "5名にプロトタイプを操作してもらう"
    fill_in "検証結果", with: "5名中4名が候補を選択できた"
    fill_in "学び", with: "候補数より比較軸が重要だった"
    fill_in "次アクション", with: "比較軸を3つに絞って再検証する"
    click_button "Sprintを作成"

    assert_text "Sprintを作成しました。"
    assert_text "利用者は比較軸が明確なら候補を選べる"
    assert_text "候補数より比較軸が重要だった"
    click_link "編集"

    fill_in "学び", with: "比較軸の名称にも説明が必要だった"
    click_button "変更を保存"

    assert_text "Sprintを更新しました。"
    assert_text "比較軸の名称にも説明が必要だった"
  end

  test "browser back after deleting a project stays on the project index with an alert" do
    project = projects(:one)
    visit project_path(project)

    accept_confirm "このプロジェクトを削除しますか？" do
      click_button "プロジェクトを削除"
    end

    assert_current_path projects_path
    assert_text "プロジェクトを削除しました。"

    page.go_back

    assert_current_path projects_path
    assert_text "このプロジェクトは削除されているため表示できません。"
  end

  test "browser back after deleting a sprint stays on the sprint index with an alert" do
    project = projects(:one)
    sprint = sprints(:one)
    visit project_sprint_path(project, sprint)

    accept_confirm "このSprintを削除しますか？" do
      click_button "削除"
    end

    assert_current_path project_sprints_path(project)
    assert_text "Sprintを削除しました。"

    page.go_back

    assert_current_path project_sprints_path(project)
    assert_text "このSprintは削除されているため表示できません。"
  end

  test "browser forward to a deleted project stays on the project index with an alert" do
    project = projects(:one)
    visit projects_path
    visit project_path(project)
    page.go_back
    assert_current_path projects_path

    project.destroy!
    page.go_forward

    assert_current_path projects_path
    assert_text "このプロジェクトは削除されているため表示できません。"
  end

  test "browser forward to a deleted sprint stays on the sprint index with an alert" do
    project = projects(:one)
    sprint = sprints(:one)
    visit project_sprints_path(project)
    visit project_sprint_path(project, sprint)
    page.go_back
    assert_current_path project_sprints_path(project)

    sprint.destroy!
    page.go_forward

    assert_current_path project_sprints_path(project)
    assert_text "このSprintは削除されているため表示できません。"
  end

  test "the main screens do not overflow a mobile viewport" do
    page.current_window.resize_to(390, 844)

    paths = [
      root_path,
      projects_path,
      new_project_path,
      project_path(projects(:one)),
      project_sprints_path(projects(:one)),
      new_project_sprint_path(projects(:one)),
      project_sprint_path(projects(:one), sprints(:one))
    ]

    paths.each do |path|
      visit path

      document_width = page.evaluate_script("document.documentElement.scrollWidth")
      viewport_width = page.evaluate_script("document.documentElement.clientWidth")
      assert_operator document_width, :<=, viewport_width, "#{path} has horizontal overflow"
    end
  end
end
