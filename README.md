## Instant Kijiji Listing Notifier
#### Kijiji Alerts aren't fast enough to beat the crowd. When every minute counts, run this program on your server to refresh that Kijiji search page for you and e-mail you when new listings appear for your search.

### Sign up with Sendgrid
With some modification, you could use a different e-mail provider, I chose Sendgrid. [Sign up for free](http://sendgrid.com/) and get your API key.

### Get your search URL
Contruct the search you want on [Kijiji](http://www.kijiji.ca/). Be sure it is ordered "Newest first" and copy the URL.

### Set your environment variables
The following environment variables must be set:

**FROM_ADDRESS**: The e-mail address the e-mail will be addressed from.

**TO_ADDRESS**: The e-mail address the e-mail will be addressed to.

**SUBJECT**: The subject of the e-mail.

**SENDGRID_KEY**: Your Sendgrid API key.

**SEARCH_URL**: Your search URL.

### Run on your server
It's ready to run on your server. Be sure it's set to respawn if necessary.

### Additional info
Two files will be created when running `scraper.rb`. `last_href_file.txt` will store the last URL to be posted for your search so that the program can be restarted without losing track of the most recent URL e-mailed to you. `email_log.txt` will keep a log of Sendgrid's responses for debugging purposes.
