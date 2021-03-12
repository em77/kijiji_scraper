require "nokogiri"
require "open-uri"
require "sendgrid-ruby"

class SendGridWrapper
  include SendGrid

  attr_reader :sg_api

  def initialize(api_key)
    @sg_api = SendGrid::API.new(api_key: api_key)
  end

  def send_email(from_address, to_address, subject, body)
    from = Email.new(email: from_address)
    to = Email.new(email: to_address)
    content = Content.new(type: "text/plain", value: body)
    mail = Mail.new(from, subject, to, content)

    response = sg_api.client.mail._("send").post(request_body: mail.to_json)
    log_email("\n\n#{response.status_code}\n#{response.body}\n#{response.headers}\n\n")
  end

  def log_email(new_log)
    File.open("email_log.txt", "a") { |file| file.print(new_log) }
  end
end

class KijijiParser
  def self.parse_search_page_results(search_page_results, last_scraped_url)
    doc = Nokogiri::HTML(search_page_results)
    search_items = doc.css("div.regular-ad")
    a_list = search_items.css("div.title a")
    urls = []
    a_list.each do |a|
      break if a["href"] == last_scraped_url
      urls << a["href"]
    end
    urls
  end
end

class Scraper
  DOMAIN = "http://www.kijiji.ca".freeze

  attr_reader :domain, :search_url, :sendgrid_wrapper

  def initialize(search_url, sendgrid_wrapper)
    @search_url = search_url
    @sendgrid_wrapper = sendgrid_wrapper
  end

  def scrape
    urls = find_new_urls

    abort "No new listings" if urls.empty?

    log_last_scraped_url(urls.first)

    urls.collect! { |url| DOMAIN + url }

    sendgrid_wrapper.send_email(
      ENV["FROM_ADDRESS"],
      ENV["TO_ADDRESS"],
      ENV["SUBJECT"],
      urls.join("\n\n")
    )
  end

  def log_last_scraped_url(last_scraped_url)
    File.open("last_scraped_log.txt", "w") { |file| file.print(last_scraped_url) }
  end

  def find_new_urls
    KijijiParser.parse_search_page_results(URI.open(search_url), last_scraped_log_contents)
  end

  def last_scraped_log_contents
    FileUtils.touch("last_scraped_log.txt") unless FileTest.exist?("last_scraped_log.txt")
    File.readlines("last_scraped_log.txt").join
  end
end

Scraper.new(ENV["SEARCH_URL"], SendGridWrapper.new(ENV["SENDGRID_KEY"])).scrape
