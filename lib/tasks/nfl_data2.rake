require 'net/http'

namespace :db do
  desc "Get schedule from nfl and populate database"
  task getnfl: :environment do
    puts "getting nfl data"

    host = 'www.nfl.com'
    path = '/schedules/2013/REG1'

    #count = 0
    # Net::HTTP.get(host, path).lines do |line|
    #   if line =~ /<span class=\"team-name (home|away) \">([A-Za-z]+)<\/span>/
    #     data = Regexp.last_match
    #     puts "[#{line.strip}] [#{data[1]}: #{data[2]}] #{count}"
    #     puts "#{count}"
    #     count = count + 1
    #   end
    # end

    # puts "count: #{count}"
    puts "count: "

  end
end
