# frozen_string_literal: true

require 'open-uri'

# 食○ログのWEBスクレイピング
class Tabelog
  attr_reader :main_contents, :current_url

  def initialize(prefecture, area)
    target = get_target_area(prefecture, area)
    @current_url = target.area_url
    @main_contents = get_main_contents(current_url)
  end

  def shop_list
    shop_list = []
    puts all_pages
    shop = Struct.new(:name, :url, :score, :image)
    return shop_list if main_contents.nil?

    main_contents.search('ul > li > div').each do |elements|
      tmp = elements.search('a.list-rst__rst-name-target')
      next if tmp.empty?

      score = elements.search('p.cpy-total-score > span').inner_text
      image = elements.search('img.cpy-main-image').attribute('data-original').value
      shop_list << shop.new(tmp.inner_text, tmp.attribute('href'), score.to_f, image)
    end
    shop_list
  end

  def sort_score(shops, sort); end

  private

  def get_target_area(prefecture, area)
    resource = get_html('https://tabelog.com/izakaya-guide/' + prefecture + '/')
    result = {}
    doc = Nokogiri::HTML.parse(resource.html, nil, resource.charset)
    hoge = doc.css('body > div.izakaya-guide-wrap > div.izakaya-guide > div.izakaya-guide__contents > section > ul > li:nth-child(n) > div > div > div > div > ul')
    hoge.search('ul > li > a').each do |elements|
      next unless elements.children.inner_text.include?(area)

      href = elements.attribute('href')
      area_name = elements.children.inner_text.strip
      result = Struct.new(:area_name, :area_url).new(area_name, href.value)
      break
    end
    result
  end

  def get_html(url)
    puts "access → #{url}"
    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read
    end
    Struct.new(:html, :charset).new(html, charset)
  end

  def get_main_contents(url)
    return nil if url.empty?

    resource = get_html(url)
    html = Nokogiri::HTML.parse(resource.html, nil, resource.charset)
    html.css('#column-main')
  end

  def all_pages
    count = main_contents.search('#column-main > div.list-condition > div.list-condition__header > h2 > span.list-condition__count').inner_text.to_f
    page_count = (count / 20).ceil
    (1..page_count).inject([]) do |list, num|
      list << current_url + num.to_s + '/'
    end
  end
end
