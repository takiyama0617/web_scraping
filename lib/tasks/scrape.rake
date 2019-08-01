# URLにアクセスするためのライブラリを読み込み
require 'open-uri'

namespace :scrape do
  desc 'NaverまとめのTechページからタイトルを取得'
  task :naver_title => :environment do
    url = 'http://matome.naver.jp/tech'

    charset = nil
    html = open(url) do |f|
      charset = f.charset # 文字種別を取得
      f.read # htmlを読み込んで変数htmlに渡す
    end

    doc = Nokogiri::HTML.parse(html, nil, charset)

    doc.xpath('//li[@class="mdTopMTMList01Item"]').each do |node|
      # タイトルの取得
      puts "・#{node.css('h3').inner_text}"
    end
  end
end
