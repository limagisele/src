# New timesheet file needs to be generated at start of every week
# It will overwrite current file
require 'json'

timesheet_file = JSON.load_file('employees.json', symbolize_names: true)
timesheet_file.each { |employee| employee.delete(:password) }
File.write('timesheets.json', JSON.pretty_generate(timesheet_file))
