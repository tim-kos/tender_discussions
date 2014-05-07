program           = require "commander"
ranger            = require "ranger"
DiscussionFetcher = require "./discussion_fetcher"

program
  .version "0.0.1"
  .option "-n, --tendersitename []", "Tender site name"
  .option "-k, --tenderapikey []", "Tender api key"
  .option "-s, --state [new]", "Discussion state, can be new, open or pending"
  .option "-ca, --campfireaccount []", "Campfire account"
  .option "-ck, --campfirekey []", "Campfire api key"
  .option "-cr, --campfireroom []", "Campfire room name"
  .parse process.argv

class DiscussionReporter
  constructor: (@name) ->
    @tenderSite   = program.tendersitename || process.env.TENDER_SITENAME
    @tenderApiKey = program.tenderapikey || process.env.TENDER_APIKEY
  
    @campfireAcc  = program.campfireaccount || process.env.CAMPFIRE_ACCOUNT
    @campfireKey  = program.campfirekey || process.env.CAMPFIRE_KEY
    @campfireRoom = program.campfireroom || process.env.CAMPFIRE_ROOM

  report: ->
    if !@tenderSite || !@tenderApiKey
      throw new Error "You need to supply Tender credentials!"

    opts =
      site   : @tenderSite,
      apiKey : @tenderApiKey,
      state  : program.state

    fetcher = new DiscussionFetcher(opts)
    fetcher.fetch (err, discussions) =>
      if err
        throw err

      if discussions.length > 0
        console.log discussions
        @_reportToCampfire discussions

  _reportToCampfire: (discussions, cb) ->
    if !this.campfireAcc
      return cb()

    client = ranger.createClient @campfireAcc, @campfireKey

    msg = "Tender discussions that we should attend to:\n"
    msg += discussions.join "\n"

    client.room @campfireRoom, (theRoom) ->
      theRoom.paste msg, cb

module.exports = DiscussionReporter
