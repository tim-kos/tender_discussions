var childProcess = require('child_process');
var async        = require('async');
var _            = require('underscore');

function DiscussionFetcher(opts) {
  this.apiKey = opts.apiKey || null;
  this.site   = opts.site   || null;
  this.state  = opts.state  || 'pending';

  this.url = this._buildUrl();

  this.numPages    = 0;
  this.err         = null;
  this.discussions = [];
}
exports.DiscussionFetcher = DiscussionFetcher;

DiscussionFetcher.prototype.fetch = function(cb) {
  var err = this._validates();
  if (err) {
    return cb(err);
  }

  var self = this;
  
  this._fetchPage(1, function() {
    if (self.pageCount < 2) {
      return self._end(cb);
    }

    var q   = async.queue(self._fetchPage.bind(self), 5);
    q.drain = function() {
      return self._end(cb);
    };

    for (var i = 2; i <= self.pageCount; i++) {
      q.push(i);
    }
  });
};

DiscussionFetcher.prototype._end = function(cb) {
  this.discussions = _.unique(this.discussions);
  cb(this.err, this.discussions);
};

DiscussionFetcher.prototype._fetchPage = function(page, cb) {
  if (this.err) {
    return cb();
  }

  var url  = this.url + '&page=' + page + '&sort=created';
  var cmd  = 'curl -H "Accept: application/vnd.tender-v1+json" ' + url;
  var self = this;

  childProcess.exec(cmd, function(err, stdout, stderr) {
    if (err) {
      self.err = err;
      return cb(err);
    }

    var parsed = null;
    try {
      parsed = JSON.parse(stdout);
    } catch(e) {
      self.err = e;
      return cb();
    }

    for (var i = 0; i < parsed.discussions.length; i++) {
      var discussion = parsed.discussions[i];
      self.discussions.push(discussion.html_href);
    }

    if (page === 1) {
      self.pageCount = Math.ceil(parsed.total / parsed.per_page);
    }

    cb();
  });
};

DiscussionFetcher.prototype._buildUrl = function() {
  var url = 'http://api.tenderapp.com/' + this.site + '/discussions/' + this.state;
  url += '?auth=' + this.apiKey;

  return url;
};

DiscussionFetcher.prototype._validates = function() {
  if (!this.apiKey) {
    return new Error('You need to set an API key.');
  }

  if (!this.site) {
    return new Error('You need to set a Tender site name.');
  }
};
