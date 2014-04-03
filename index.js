var DiscussionFetcher = require('./lib/discussion_fetcher').DiscussionFetcher;

var opts = {
  site   : 'YOUR_TENDER_SITE_NAME',
  apiKey : 'YOUR_TENDER_API_KEY',
  state  : 'open' // the discussion state, can be "open" or "pending"
};

var fetcher = new DiscussionFetcher(opts);
fetcher.fetch(function(err, discussions) {
  if (err) {
    throw err;
  }

  console.log(discussions);
});
