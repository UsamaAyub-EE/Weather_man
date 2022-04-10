require 'csv'
require 'matrix'
require 'colorize'

months = %w[not January February March April May June July August September October November December]
short_months = months.map { |month| month[0, 3] }       #this array will store first three characters of month names

#class to be added
module CSV_file_handler
  class CSV_to_List
    def csv_to_list(list_of_filenames)
      array = []
      for filename in list_of_filenames
        CSV.foreach((filename), headers: true, col_sep: ",") do |row|          #code to read csv file and save data to array
          array << row
        end
      end
      array
    end
  end
end
#puts short_months
#for i in 0 ... ARGV.length
#  puts "#{i} #{ARGV[i]}"
#end
filenames = Dir[ARGV[2] + "*"]      #ARGV[2] is the folder path and Dir will return a list of all filenames in the folder
if ARGV[0] == '-e'

  filenames = filenames.select {|filename| filename.include?(ARGV[1]) }       #ARGV[1] is the year
  #puts filenames

  array = CSV_file_handler::CSV_to_List.new.csv_to_list(filenames)
  array.shift        #remove the header information
  #puts array[0]

  max_temp = -99
  max_temp_date = ""
  min_temp = 1000
  min_temp_date = ""
  max_humid = -1
  max_humid_date = ""

  array.each do |row|
    if row[1].to_i.to_s == row[1] && row[1].to_i > max_temp         # row[1].to_i.to_s == row[1] : this code checks if row[1] is a string that is a number e.g. "22"
      max_temp = row[1].to_i       #second column contains max temperature
      max_temp_date = row[0]       #first column contains dates
    end
    if row[3].to_i.to_s == row[3] && row[3].to_i < min_temp
      min_temp = row[3].to_i       #fourth column contains min temperature
      min_temp_date = row[0]       #first column contains dates
    end
    if row[7].to_i.to_s == row[7] && row[7].to_i > max_humid
      max_humid = row[7].to_i       #Eigth column contains max humidity
      max_humid_date = row[0]       #first column contains dates
    end
  end
  #puts max_temp
  ymd_max_temp = max_temp_date.split('-')         #ymd is year month day
  ymd_min_temp = min_temp_date.split('-')
  ymd_max_humid = max_humid_date.split('-')
  #puts months[ymd_max_temp[1].to_i]
  #puts ymd_max_temp[-1]
  puts "Highest: #{max_temp}C on #{ months[ymd_max_temp[1].to_i] } #{ymd_max_temp[-1]}"
  puts "Lowest: #{min_temp}C on #{ months[ymd_min_temp[1].to_i] } #{ymd_min_temp[-1]}"
  puts "Humid: #{max_humid}% on #{ months[ymd_max_humid[1].to_i] } #{ymd_max_humid[-1]}"

elsif ARGV[0] == '-a'
  #puts 'Got -a'
  year_month = ARGV[1].split('/')     #extract year and month
  #puts year_month
  filenames = filenames.select {|filename| ( filename.include?(year_month[0]) && filename.include?( short_months[ year_month[1].to_i ] ) ) }
  # select the filename that contains the year and the short version of the month
  #puts filenames

  array = CSV_file_handler::CSV_to_List.new.csv_to_list(filenames)
  array.shift        #remove the header information

  sum_high_avg = 0
  sum_low_avg = 0
  sum_avg_humid = 0
  count_high_avg = 0
  count_low_avg = 0
  count_avg_humid = 0
  array.each do |row|
    if row[1].to_i.to_s == row[1]
      sum_high_avg += row[1].to_i       #second column contains max temperature
      count_high_avg += 1
    end
    if row[3].to_i.to_s == row[3]
      sum_low_avg += row[3].to_i       #fourth column contains min temperature
      count_low_avg += 1
    end
    if row[8].to_i.to_s == row[8]
      sum_avg_humid += row[8].to_i       #ninth column contains mean humidity
      count_avg_humid += 1
    end
  end
  puts "Highest Average: #{sum_high_avg / count_high_avg}C"
  puts "Lowest Average: #{sum_low_avg / count_low_avg}C"
  puts "Average Humidity: #{sum_avg_humid / count_avg_humid}%"

elsif ARGV[0] == '-c'
  #puts 'Got -c'
  year_month = ARGV[1].split('/')     #extract year and month
  date = year_month.join('-')
  #puts year_month
  filenames = filenames.select {|filename| ( filename.include?(year_month[0]) && filename.include?( short_months[ year_month[1].to_i ] ) ) }
  # select the filename that contains the year and the short version of the month
  #puts filenames

  array = CSV_file_handler::CSV_to_List.new.csv_to_list(filenames)
  array.shift        #remove the header information

  puts "#{months[ year_month[1].to_i ]} #{year_month[0]}"
  array.each do |row|
    if row[0].start_with?(date)
      ymd = row[0].split('-')
      print ymd[-1] + ' '
      STDOUT.flush        #this is needed to remove the newline printed by print
      if row[1].to_i.to_s == row[1]
        high_temp = row[1].to_i          #second column contains max temperature
        high_temp.times do
          print "+".red
          STDOUT.flush
        end
        puts " #{high_temp}C"
      end
      print ymd[-1] + ' '
      STDOUT.flush
      if row[3].to_i.to_s == row[3]      #fourth column contains min temperature
        low_temp = row[3].to_i
        low_temp.times do
          print "+".blue
          STDOUT.flush
        end
        puts " #{low_temp}C"
      end
    end
  end
else
  puts 'Got garbage'
end
