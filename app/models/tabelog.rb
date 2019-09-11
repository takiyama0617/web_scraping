require 'open-uri'

class Tabelog
  def initialize
  end

  def get_store(prefecture)
    url = 'https://tabelog.com/' + prefecture + '/'
    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read
    end

    result = []
    doc = Nokogiri::HTML.parse(html, nil, charset)
    doc.xpath('//*[@id="column-main"]/ul/li/div/div/div/div/div/a').each do |node|
      result << node.inner_text
    end
    result
  end

  def sort_score(shops, sort)
  end
end