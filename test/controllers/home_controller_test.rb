require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
    assert_select "html[lang='ja']"
    assert_select "header.site-header"
    assert_select "nav[aria-label='メインナビゲーション']"
    assert_select "a.skip-link[href='#main-content']", text: "本文へ移動"
    assert_select "h1", text: /仮説を/
  end
end
