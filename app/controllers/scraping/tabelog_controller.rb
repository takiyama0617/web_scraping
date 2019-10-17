# frozen_string_literal: true

module Scraping
  # 食○ログ スクレイピング
  class TabelogController < ApplicationController
    def show
      prefecture = params[:prefecture]
      area = params[:area]
      tabelog = Tabelog.new(prefecture, URI.unescape(area))
      @shops = tabelog.shop_list
    end
  end
end
