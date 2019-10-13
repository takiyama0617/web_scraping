# frozen_string_literal: true

require 'open-uri'

# 食○ログのWEBスクレイピング
class Tabelog
  def initialize; end

  def get_store(url)
    resource = get_html(url)
    result = []
    shop = Struct.new(:name, :url, :score, :image)
    doc = Nokogiri::HTML.parse(resource.html, nil, resource.charset)
    doc.xpath('//*[@id="column-main"]/ul/li/div').each do |elements|
      tmp = elements.search('a.list-rst__rst-name-target')
      next if tmp.empty?

      score = elements.search('p.cpy-total-score > span').inner_text
      image = elements.search('img.cpy-main-image').attribute('data-original').value
      result << shop.new(tmp.inner_text, tmp.attribute('href'), score.to_f, image)
    end
    result
  end

  def get_target_area(prefecture, area)
    resource = get_html('https://tabelog.com/izakaya-guide/' + prefecture + '/')
    result = {}
    doc = Nokogiri::HTML.parse(resource.html, nil, resource.charset)
    doc.xpath('/html/body/div[4]/div[2]/div[2]/section/ul/li/div/div/div/div/ul/li/a').each do |elements|
      href = elements.attribute('href')
      str = elements.children.reduce do |_txt, ele|
        next if ele.text?
        next unless ele.children.inner_text.include?(area)

        txt = ele.children.inner_text
      end
      result = Struct.new(:area_name, :area_url).new(str, href.value) unless str.to_s.empty?
    end
    result
  end

  def sort_score(shops, sort); end

  private

  def get_html(url)
    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read
    end
    Struct.new(:html, :charset).new(html, charset)
  end
end
