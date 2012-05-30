# node-feedparser-stream
# Copyright(c) 2012 Philipp Spieß <hello@philippspiess.com>
# MIT Licensed

FeedParserStream = require '../index'

parser = new FeedParserStream
  interval: 1000 # every second ;)
  includeFirst: false
  debug: true

parser.on 'article', (article) ->
  console.log '\n  %s\n  Date: %s', article.title, article.pubdate

parser.parseUrl 'http://techcrunch.com/feed'

# Exit after 20 seonds.
#
#  setTimeout ->
#   parser.exit()
#   console.log 'exit'
# , 20000
