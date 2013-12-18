#!/home/yan/.rbenv/versions/1.9.3-rc1/bin/ruby
# -*- encoding: utf-8 -*-

$: .unshift File.dirname(__FILE__)

pwd = File.dirname(__FILE__)
require "peddling"


peddlings = read_peddrings("#{pwd}/../event")

print "Content-type: text/html\n\n"

print export_past_peddling(peddlings)
