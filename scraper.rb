#!/bin/env ruby
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

require_rel 'lib'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def scrape(pair)
  url, klass = pair.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

start = 'http://www.cdep.ro/pls/parlam/structura2015.de?leg=2016&idl=2'
data = scrape(start => MembersPage).members.map do |mem|
  mem.to_h.merge(scrape(mem.source => MemberPage).to_h)
end
data.each { |mem| puts mem.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h } if ENV['MORPH_DEBUG']

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
ScraperWiki.save_sqlite(%i[id term], data)
