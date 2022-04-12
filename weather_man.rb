# frozen_string_literal: true

require 'csv'
require 'matrix'
require 'colorize'

$months = %w[not January February March April May June July August September October November December]
$short_months = $months.map { |month| month[0, 3] } # this array will store first three characters of month names

module CSV_file_handler
  class CSV_to_List
    def csv_to_list(list_of_filenames)
      array = []
      list_of_filenames.each do |filename|
        CSV.foreach(filename, headers: true, col_sep: ',') do |row| # code to read csv file and save data to array
          array << row
        end
      end
      array
    end
  end
end

module Report_gen
  def self.report_e_gen(data_array)
    max_temp = -99
    max_temp_date = ''
    min_temp = 1000
    min_temp_date = ''
    max_humid = -1
    max_humid_date = ''
    data_array.each do |row|
      if row[1].to_i.to_s == row[1] && row[1].to_i > max_temp # row[1].to_i.to_s == row[1] : this code checks if row[1] is a string that is a number e.g. "22"
        max_temp = row[1].to_i       # second column contains max temperature
        max_temp_date = row[0]       # first column contains dates
      end
      if row[3].to_i.to_s == row[3] && row[3].to_i < min_temp
        min_temp = row[3].to_i       # fourth column contains min temperature
        min_temp_date = row[0]       # first column contains dates
      end
      if row[7].to_i.to_s == row[7] && row[7].to_i > max_humid
        max_humid = row[7].to_i       # Eigth column contains max humidity
        max_humid_date = row[0]       # first column contains dates
      end
    end
    ymd_max_temp = max_temp_date.split('-')
    ymd_min_temp = min_temp_date.split('-')
    ymd_max_humid = max_humid_date.split('-')
    puts "Highest: #{max_temp}C on #{$months[ymd_max_temp[1].to_i]} #{ymd_max_temp[-1]}"
    puts "Lowest: #{min_temp}C on #{$months[ymd_min_temp[1].to_i]} #{ymd_min_temp[-1]}"
    puts "Humid: #{max_humid}% on #{$months[ymd_max_humid[1].to_i]} #{ymd_max_humid[-1]}"
  end

  def self.report_a_gen(data_array)
    sum_high_avg = 0
    sum_low_avg = 0
    sum_avg_humid = 0
    count_high_avg = 0
    count_low_avg = 0
    count_avg_humid = 0 # initializations
    data_array.each do |row|
      if row[1].to_i.to_s == row[1]
        sum_high_avg += row[1].to_i
        count_high_avg += 1 # second column contains max temperature
      end
      if row[3].to_i.to_s == row[3]
        sum_low_avg += row[3].to_i
        count_low_avg += 1 # fourth column contains min temperature
      end
      if row[8].to_i.to_s == row[8]
        sum_avg_humid += row[8].to_i
        count_avg_humid += 1 # ninth column contains mean humidity
      end
    end
    puts "Highest Average: #{sum_high_avg / count_high_avg}C \nLowest Average: #{sum_low_avg / count_low_avg}C \nAverage Humidity: #{sum_avg_humid / count_avg_humid}%"
  end

  def self.report_c_gen(data_array, date)
    data_array.each do |row|
      next unless row[0].start_with?(date)

      ymd = row[0].split('-')
      print "#{ymd[-1]} "
      $stdout.flush # this is needed to remove the newline printed by print
      if row[1].to_i.to_s == row[1]
        high_temp = row[1].to_i # second column contains max temperature
        high_temp.times do
          print '+'.red
          $stdout.flush
        end
        puts " #{high_temp}C"
      end
      print "#{ymd[-1]} "
      $stdout.flush
      next unless row[3].to_i.to_s == row[3] # fourth column contains min temperature

      low_temp = row[3].to_i
      low_temp.times do
        print '+'.blue
        $stdout.flush
      end
      puts " #{low_temp}C"
    end
  end
end
case ARGV[0]
when '-e'
  filenames = Dir["#{ARGV[2]}*"] # ARGV[2] is the folder path and Dir will return a list of all filenames in the folder
  filenames = filenames.select { |filename| filename.include?(ARGV[1]) } # ARGV[1] is the year

  array = CSV_file_handler::CSV_to_List.new.csv_to_list(filenames)
  array.shift # remove the header information

  Report_gen.report_e_gen(array)

when '-a'
  year_month = ARGV[1].split('/')     # extract year and month
  filenames = Dir["#{ARGV[2]}*"]      # ARGV[2] is the folder path and Dir will return a list of all filenames in the folder
  filenames = filenames.select do |filename|
    (filename.include?(year_month[0]) && filename.include?($short_months[year_month[1].to_i]))
  end
  # select the filename that contains the year and the short version of the month

  array = CSV_file_handler::CSV_to_List.new.csv_to_list(filenames)
  array.shift # remove the header information

  Report_gen.report_a_gen(array)

when '-c'
  year_month = ARGV[1].split('/')     # extract year and month
  date = year_month.join('-')
  filenames = Dir["#{ARGV[2]}*"]      # ARGV[2] is the folder path and Dir will return a list of all filenames in the folder
  filenames = filenames.select do |filename|
    (filename.include?(year_month[0]) && filename.include?($short_months[year_month[1].to_i]))
  end
  # select the filename that contains the year and the short version of the month

  array = CSV_file_handler::CSV_to_List.new.csv_to_list(filenames)
  array.shift        # remove the header information

  puts "#{$months[year_month[1].to_i]} #{year_month[0]}"
  Report_gen.report_c_gen(array, date)

else
  puts 'Got garbage'
end
