require 'open-uri'

class Tabelog
  def initialize
  end

  def get_store
    url = 'https://tabelog.com/kanagawa/A1404/A140403/'
    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read
    end

    doc = Nokogiri::HTML.parse(html, nil, charset)
    doc.xpath('//*[@id="column-main"]/ul/li[1]/div[2]/div[1]/div/div/div/a').each do |node|
      puts node.inner_text
    end
  end
end