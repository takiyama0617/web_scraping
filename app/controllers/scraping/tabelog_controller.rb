# frozen_string_literal: true

class Scraping::TabelogController < ApplicationController
  def show
    prefecture = params[:prefecture]
    area = params[:area]
    tabelog = Tabelog.new
    target_area = tabelog.get_target_area(prefecture, URI.unescape(area))
    @shops = tabelog.get_store(target_area.area_url)
  end
end
