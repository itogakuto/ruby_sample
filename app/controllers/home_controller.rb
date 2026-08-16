class HomeController < ApplicationController
  def index
    @app_name = "Agile Outcome Canvas"
    @description = "顧客価値仮説と検証結果を記録するアプリです。"
  end
end
