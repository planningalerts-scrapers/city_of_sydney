require 'scraperwiki'
require 'rss/2.0'
require 'date'

feed = RSS::Parser.parse("http://feeds.cityofsydney.nsw.gov.au/SydneyDAs", false)

feed.channel.items.each do |item|
  info_url = item.description.split('<a href="')[1].split('">View')[0]

  info_url.sub! 'DAsOnExhibition/details.asp?tpk=', 'DASearch/Detail.aspx?id='

  description = item.description.split('p>')[3].gsub('</','')

  exhibition_closes = item.description.split(/Exhibition Closes: \<\/strong\>/i)[1].split('</p>')[0]
  on_notice_to = Date.parse(exhibition_closes).strftime('%Y-%m-%d')

  record = {
    "address" => item.title.gsub(' *NEW*',''),
    "description" => description,
    "date_received" => item.pubDate.strftime('%Y-%m-%d'),
    "on_notice_to" => on_notice_to,
    "council_reference" => item.description.split('DA Number: </strong>')[1].split('<p>')[0],
    "info_url" => info_url,
    "comment_url" => "mailto:dasubmissions@cityofsydney.nsw.gov.au",
    "date_scraped" => Date.today.to_s
  }

  if (ScraperWiki.select("* from data where `council_reference`='#{record['council_reference']}'").empty? rescue true)
    ScraperWiki.save_sqlite(['council_reference'], record)
  else
    puts "Skipping already saved record " + record['council_reference']
  end
end