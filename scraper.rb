require 'scraperwiki'
require 'rss/2.0'
require 'date'
require 'nokogiri'

feed = RSS::Parser.parse("http://feeds.cityofsydney.nsw.gov.au/SydneyDAs", false)

feed.channel.items.each do |item|
  parts = /<p>(.*)<\/p><p>(.*)<\/p><p>(.*)<\/p><p>(.*)<\/p><p>(.*)<\/p>/.match(item.description)

  address, council_ref, description, closing, info_url = parts.captures
  
  info_url = /<a href="([^"]+)"/.match(info_url)[1]
  info_url.sub! 'DAsOnExhibition/details.asp?tpk=', 'DASearch/Detail.aspx?id='

  description = Nokogiri::HTML.parse(description.gsub(/<\/?strong>/, '')).text
  council_ref = /<strong>\s*DA Number:\s*<\/strong>(.+)/i.match(council_ref)[1]
  exhibition_closes = /<strong>\s*Exhibition Closes:\s*<\/strong>(.+)/i.match(closing)[1]
  
  on_notice_to = Date.parse(exhibition_closes).strftime('%Y-%m-%d')

  record = {
    "address" => item.title.gsub(' *NEW*',''),
    "description" => description,
    "date_received" => item.pubDate.strftime('%Y-%m-%d'),
    "on_notice_to" => on_notice_to,
    "council_reference" => council_ref,
    "info_url" => info_url,
    "comment_url" => "mailto:dasubmissions@cityofsydney.nsw.gov.au",
    "date_scraped" => Date.today.to_s
  }

  ScraperWiki.save_sqlite(['council_reference'], record)
end
