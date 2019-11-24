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
    shop = Struct.new(:name, :url, :score, :image)
    all_pages.each do |url|
      get_main_contents(url).search('ul > li > div').each do |elements|
        tmp = elements.search('a.list-rst__rst-name-target')
        next if tmp.empty?

        score = elements.search('p.cpy-total-score > span').inner_text
        image = elements.search('img.cpy-main-image').attribute('data-original').value
        shop_list << shop.new(tmp.inner_text, tmp.attribute('href'), score.to_f, image)
      end
    end
    shop_list
  end

  def sort_score(shops, sort); end

  private

  def get_target_area(prefecture, area)
    resource = get_html(['https://tabelog.com/izakaya-guide/' + prefecture + '/'])
    result = {}
    doc = Nokogiri::HTML.parse(resource[0].html, nil, resource[0].charset)
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

  def get_html(urls = [])
    hydra = Typhoeus::Hydra.new
    requests = urls.map do |url|
      puts "access : #{url}"
      request = Typhoeus::Request.new(url)
      hydra.queue(request)
      request
    end
    hydra.run

    responses = requests.map do |request|
      html = request.response.body
      Struct.new(:html, :charset).new(html, 'utf-8')
    end
    responses
  end

  def get_main_contents(url)
    return nil if url.empty?

    resources = get_html([url])
    m = nil
    resources.each do |resource|
      html = Nokogiri::HTML.parse(resource.html, nil, resource.charset)
      m = html.css('#column-main')
    end
    m
  end

  def all_pages
    count = main_contents.search('#column-main > div.list-condition > div.list-condition__header > h2 > span.list-condition__count').inner_text.to_f
    page_count = (count / 20).ceil
    (1..page_count).inject([]) do |list, num|
      list << current_url + num.to_s + '/'
    end
  end
end
