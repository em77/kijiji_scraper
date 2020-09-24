require "nokogiri"
require "open-uri"
require "sendgrid-ruby"
include SendGrid

def replace_file_contents(string, file_name)
  file = File.new(file_name, "w")
  file.print(string)
  file.close
end

def write_to_file(string, file_name)
  file = File.new(file_name, "a")
  file.print(string)
  file.close
end

def send_email(from_address, to_address, subject_string, body_string, sg_key)
  from = Email.new(email: from_address)
  to = Email.new(email: to_address)
  content = Content.new(type: "text/plain", value: body_string)
  mail = Mail.new(from, subject_string, to, content)

  sg = SendGrid::API.new(api_key: sg_key)
  response = sg.client.mail._("send").post(request_body: mail.to_json)
  log = "\n\n#{response.status_code}\n#{response.body}\n#{response.headers}\n\n"
  write_to_file(log, "email_log.txt")
end

def search_urls(search_url, last_href)
  doc = Nokogiri::HTML(open(search_url))
  search_items = doc.css("div.regular-ad")
  a_list = search_items.css("div.title a")
  urls = []
  a_list.each do |a|
    break if a["href"] == last_href
    urls << a["href"]
  end
  urls
end

def url_prepender(domain_to_prepend, url_string)
  domain_to_prepend + url_string
end

domain = "http://www.kijiji.ca"

urls = search_urls(ENV["SEARCH_URL"], File.readlines("last_href_file.txt").join)

break if urls.empty?

replace_file_contents(urls.first, "last_href_file.txt")

urls.collect! {|url| url_prepender(domain, url)}

send_email(ENV["FROM_ADDRESS"],
           ENV["TO_ADDRESS"],
           ENV["SUBJECT"],
           urls.join("\n\n"),
           ENV["SENDGRID_KEY"])

# Test e-mail body output in terminal
# puts urls.join("\n")
