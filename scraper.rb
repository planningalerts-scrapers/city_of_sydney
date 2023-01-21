require 'scraperwiki'
require 'date'
require "mechanize"

class String
  def squish
    string = strip
    string.gsub!(/\s+/, ' ')
    string
  end
end

def convert_date(s)
  Date.strptime(s, "%d/%m/%Y").to_s
rescue ArgumentError
  nil
end

agent = Mechanize.new

site = "https://eplanning.cityofsydney.nsw.gov.au"
url = "https://eplanning.cityofsydney.nsw.gov.au/Pages/XC.Track/SearchApplication.aspx?e=y"

page = agent.get(url)
puts "#{url} loaded"
csvTable = page.at(".csvTable")
count = 0

csvTable.element_children.map.each do |application|
  next if application['class'] == "headerRow"
  count = count + 1

  info_url = application.at("#applicationReference a")['href'].squish.sub("../..",site)
  # split bad concat addresses by strings that look like postcodes, but include the string we split on in the result 
  addresses = application.at("#applicationAddress").inner_text.squish.split(/(NSW \d{4})/).each_slice(2).map(&:join)

  record = {
    "address" => addresses.first,
    "description" => application.at("#applicationDetails").inner_text.squish,
    "date_received" => convert_date(application.at("#lodgementDate").inner_text.squish),
    "on_notice_to" => convert_date(application.at("#exhibitionCloseDate").inner_text.squish),
    "council_reference" => application.at("#applicationReference a").inner_text.squish,
    "info_url" => info_url,
    "comment_url" => "mailto:dasubmissions@cityofsydney.nsw.gov.au",
    "date_scraped" => Date.today.to_s
  }
  puts record
  ScraperWiki.save_sqlite(['council_reference'], record)
end

# Return number of applications found
puts count