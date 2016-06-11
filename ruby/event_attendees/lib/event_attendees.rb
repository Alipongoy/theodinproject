require 'csv'
require 'sunlight/congress'
require 'erb'
require 'pry'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(row_number, form_letter)
  file_name = "output/thanks_#{row_number}.html"
  Dir.mkdir('output') unless Dir.exists? 'output'
  File.open(file_name, 'w') {|file| file.puts form_letter}
end

def clean_phone_number(phone_number)
  p phone_number
  phone_number = phone_number.gsub(/^:digit/, " ")
  p phone_number
  phone_number_length = phone_number.length
  
  if phone_number_length == 10
    phone_number
  elsif phone_number_length < 10 || phone_number_length > 11
    " "
  elsif phone_number_length == 11
    if phone_number[0] == 1
      phone_number[1..phone_number_length-1]
    else
      " "
    end
  end
end

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

template_letter = File.read "template.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  name = row[:first_name]
  row_number = row[:row]
  zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_number(row[:homephone])

  legislators = legislators_by_zipcode(zipcode)
  form_letter = erb_template.result(binding)
  save_thank_you_letters(row_number, form_letter)
end