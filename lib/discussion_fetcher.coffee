childProcess = require "child_process"
async        = require "async"
_            = require "underscore"

class DiscussionFetcher
  constructor: (opts) ->
    @apiKey = opts.apiKey || null
    @site   = opts.site   || null
    @state  = opts.state  || "pending"

    @url = @_buildUrl()
    @numPages    = 0
    @err         = null
    @discussions = []

  _buildUrl: ->
    url = "http://api.tenderapp.com/" + @site + "/discussions/" + @state
    url += "?auth=" + @apiKey
    return url

  _validates: ->
    if !@apiKey
      return new Error "You need to set an API key."

    if !@site
      return new Error "You need to set a Tender site name."

  fetch: (cb) ->
    err = @_validates()
    if err
      return cb err
   
    @_fetchPage 1, =>
      if @pageCount < 2
        return @_end cb

      q = async.queue @_fetchPage, 5
      q.drain = ->
        return @_end cb

      for num in [2..@pageCount]
        q.push num

  _end: (cb) ->
    @discussions = _.unique @discussions
    cb @err, @discussions

  _fetchPage: (page, cb) ->
    if @err
      return cb()

    url = @url + "&page=" + page + "&sort=created"
    cmd = "curl -H \"Accept: application/vnd.tender-v1+json\" " + url

    childProcess.exec cmd, (err, stdout, stderr) =>
      if err
        @err = err
        return cb err

      parsed = null
      try
        parsed = JSON.parse stdout
      catch e
        @err = e
        return cb()

      for num in [0..parsed.discussions.length - 1]
        discussion = parsed.discussions[num]

        entry = discussion.title + " -- " + discussion.html_href
        @discussions.push entry

      if page == 1
        @pageCount = Math.ceil parsed.total / parsed.per_page

      cb()

module.exports = DiscussionFetcher
