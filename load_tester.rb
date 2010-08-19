#!/usr/bin/env ruby

require 'bundler/setup'
require 'yaml'
require "em-synchrony"
require "em-synchrony/iterator"
require "em-synchrony/em-http"
require_relative 'load_test'

config = YAML::load_file('config.yml')

url = LoadTest.add_http(config['url'])

EM.synchrony do
  EM::Synchrony::Iterator.new(1..config['repeats'], config['clients']).map do |num,iter|
    start_time = Time.now
    http = EventMachine::HttpRequest.new(url).aget
    http.callback { 
      end_time = Time.now
      test = LoadTest.create(start_time: start_time, end_time: end_time, clients: config['clients'], url: url)
      puts "#{num}: #{test.inspect}" if config["verbose"]
      iter.return(http)
    }
  end
  
  if config['statistics']
    puts "\nStatistics:"
    LoadTest.print_statistics(LoadTest.order("time_taken desc"))
  end
  EM.stop
end

