require 'active_record'

dbconfig = YAML::load_file('database.yml')
ActiveRecord::Base.establish_connection(dbconfig)

ActiveRecord::Schema.define do
  create_table :load_tests do |t|
    t.string   :url
    t.datetime :start_time
    t.datetime :end_time
    t.float    :time_taken
    t.integer  :clients
  end 
  [:url, :start_time, :end_time, :time_taken].each do |column|
    add_index :load_tests, column
  end
end unless ActiveRecord::Base.connection.table_exists? :load_tests

class LoadTest < ActiveRecord::Base
  validates_presence_of :url, :start_time, :end_time, :clients

  before_save { |test| test.time_taken = test.end_time - test.start_time }

  def self.add_http(url)
    url = url =~ /http:\/\// ? url : 'http://' + url
  end

  def self.print_statistics(scope = scoped)
    line =  '+-------+--------------------------------------------+-----------------------+------------------------+'
    puts line
    puts    '| tests |                    url                     |        average        |   standart deviation   |'
    puts line 
    statistics.each do |h|
      url = h[:url].length > 42 ? h[:url][0..38]+'...' : "%42s"%h[:url]
      puts "| #{'%5d'%h[:tests]} | #{url} | #{'%21s'%h[:average]} | #{'%22s'%h[:standart_deviation]} |" 
    end
    puts line 
  end

  def self.statistics(scope = scoped)
    means = scope.group(:url).average(:time_taken)
    std = {}
    means.each do |url, avg|
      sum = scope.where(url: url).inject(0){|acc, t| acc + (t.time_taken-avg)**2 }
      std[url] = 1/(scope.where(url: url).count*sum)
    end
    means.keys.collect do |url|
      { tests: scope.where(url: url).count, url: url, average: means[url], 
        standart_deviation: std[url]
      }
    end
  end
end
