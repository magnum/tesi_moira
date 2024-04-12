require 'csv'
require 'active_support/all'

def datetimeFromString(str)
  DateTime.strptime(str, "%d/%m/%y %H.%M")
end


def parse(file)
  items = {}
  years_max = {}
  sum = 0
  CSV.foreach(file, headers: true, col_sep: ";").with_index do |row, row_index|
    # parse date in this format "DD/MM/YY 00.00"
    if row_index < 1000000
      datetime = datetimeFromString(row[0])
      timestamp = datetime.strftime("%s").to_i
      timestamp_step = timestamp - (timestamp % 1800) 
      # calculate difference in minutes
      #diff = ((datetime - datetime_ref) * 24 * 60).to_i
      puts "#{datetime}, timestamp: #{timestamp}, timestamp_step: #{timestamp_step}" #diff minutes: #{diff}"
      items[timestamp_step] = {datetimes: [], values: [], sum: 0.0} unless items[timestamp_step]
      items[timestamp_step][:datetimes] << datetime
      value = row["value"].to_f
      items[timestamp_step][:values] << value
      items[timestamp_step][:sum] += value
    end
  end

  items.each do |key, item|
    puts "#{key}: datetimes: #{item[:datetimes].join(", ")}, values: #{item[:values].join(", ")}, sum: #{item[:sum]}"
  end

  
  items.each do |key, item|
    datetime = item[:datetimes].first
    years_max[datetime.year] = 0 unless years_max[datetime.year] 
    years_max[datetime.year] = item[:sum] if item[:sum] > years_max[datetime.year]
  end

  CSV.open("output1_years.csv", "wb") do |csv|
    years_max.each do |key, item|
      csv << [
        key,item.round(2)
      ]
    end
  end
  

  # save items
  #return
  CSV.open("output1.csv", "wb") do |csv|
    items.each do |key, item|
      csv << [
        item[:datetimes].first.strftime("%d/%m/%y %H.%M"),
        item[:sum].round(2)
      ]
    end
  end
end

parse ARGV[0]