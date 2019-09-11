class Scraping::TabelogController < ApplicationController
  def show
    prefecture = params[:prefecture]
    @prefecture = prefecture
    tabelog = Tabelog.new
    @shops = tabelog.get_store(prefecture)
  end
end