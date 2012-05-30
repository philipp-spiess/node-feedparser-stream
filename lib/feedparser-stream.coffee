# node-feedparser-stream
# Copyright(c) 2012 Philipp Spieß <hello@philippspiess.com>
# MIT Licensed

FeedParser = require 'feedparser'
events = require 'events'
_ = require 'underscore'

# This class combines all the power and magic of `feedparser` and `EventEmitter`
class FeedParserStream extends events.EventEmitter
  
  # The **constuctor**. 
  #
  # Its first argument is optional and an object of options, see the default options.
  constructor: (options) ->
    unless options?
      options = {}

    @opt = _.defaults options,
      includeFirst: true
      interval: 60000 # Every minute
      debug: false
    
    @parser = new FeedParser

  # This will **fetch an url** and all it's articles.
  # 
  # If options.includeFirst is set to null we will skip pushing these articles
  # but still need to fetch them to find out what is the latest one.
  parseUrl: (@url) =>
    @parser.parseUrl @url, (err, meta, articles) =>
      if err?
        throw err
      else
        # The last one should be fired at first, this is because we want a streaming feeling :)
        articles = articles.reverse()

        # Now it's time to save tha last one and push it to the client ;)
        for article in articles
          if @opt.includeFirst
            @emit 'article', article
          @last = article

        # Now it's time to start the polling, good luck!
        @poll()

  # **Poll** it!
  poll: =>
    @timeout = _.delay @operate, @opt.interval     

  # This will **exit the stream**
  exit: =>
    clearTimeout @timeout

  # This will be called every interval.
  #
  # We **fetch the newest article** and see what changed.
  operate: =>
    @parser.parseUrl @url, (err, meta, articles) =>
      if err?
        throw err
      else
        # Again, we need to start with the last one
        articles = articles.reverse()

        # This is a little bit dirty.
        #
        # To check for the newest article i take an empty array and fill it with all the articles,
        # which are not equal to the last article. There may be older articles, therefore we have
        # to reset the array if we find an equivalent. 
        new_articles = []
        for article in articles
          if @equals article, @last
            new_articles = []
          else
            new_articles.push article

        if @opt.debug
          process.stdout.write '.'

        for article in new_articles
          @emit 'article', article
          @last = article

        @poll()

  # Find out **if two articles are equal**
  #
  # @Todo: find a good algorithm if something changes
  equals: (article1, article2) =>
    if article1.link is article2.link
      true
    else
      false

# Over and out
module.exports = FeedParserStream