require 'date'
require 'time'
require 'json'
require 'csv'
require 'tty-prompt'
require 'rainbow/refinement'
using Rainbow
require './classes/timesheet'
require './classes/employee'
require './classes/errors'
require './module/payable_leave'

ts = JSON.load_file('report.json', symbolize_names: true)

CSV.open('report2.csv', 'a') do |csv|
    ts.each do |hash|
        hash[:timesheets].each do |hash2|
            csv << hash2.values
        end
    end
end
