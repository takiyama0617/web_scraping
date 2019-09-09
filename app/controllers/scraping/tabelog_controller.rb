class Scraping::TabelogController < ApplicationController
  def show
    prefecture = params[:prefecture]
    @prefecture = prefecture
    tabelog = Tabelog.new
    tabelog.get_store
  end
end