#!/Users/yan/.rbenv/versions/1.9.3-rc1/bin/ruby -E utf-8
# -*- encoding: utf-8 -*-

$: .unshift File.dirname(__FILE__)

pwd = File.dirname(__FILE__)
require "dress"


dresses = read_dresses("#{pwd}/../dress")

print "Content-type: text/html\n\n"

print export_dress_list(dresses)
