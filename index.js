#!/usr/bin/env node

var program = require('commander');

program
  .version('0.0.1')
  .option('-s, --site', 'Tender site name')
  .option('-k, --apikey', 'Tender api key')
  .parse(process.argv);

var DiscussionFetcher = require('./lib/discussion_fetcher').DiscussionFetcher;

var opts = {
  site   : program.site,
  apiKey : program.apikey,
  state  : 'pending' // the discussion state, can be "new", "open" or "pending"
};

var fetcher = new DiscussionFetcher(opts);
fetcher.fetch(function(err, discussions) {
  if (err) {
    throw err;
  }

  console.log(discussions);
});
