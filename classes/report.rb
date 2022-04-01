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

# Include methods to generate json and csv files for managers access
class Report
    @@employee_file = JSON.load_file('json_files/employees.json', symbolize_names: true)
    @@headers = ["Name", "ID", "Clock-In", "Clock-Out", "Working Hours", "Leave Applied", "Leave Minutes"]
    @@prompt = TTY::Prompt.new(interrupt: :exit)

    def self.employee_file
        return @@employee_file
    end

    def self.headers
        return @@headers
    end

    # New timesheet file needs to be generated at start of every week (new payroll)
    # It will overwrite current file
    def self.generate_json
        input = @@prompt.yes?("This will erase all current saved timesheets. Proceed?")
        if input == true
            employee_file.each { |employee| employee.delete(:password) }
            File.write('json_files/timesheets.json', JSON.pretty_generate(employee_file))
            puts "\n Timesheet file is now ready for a new payroll cycle! \n".bg(:yellow).black
        end
    rescue FileError => e
        @@prompt.error(e.message)
    end

    # Generate csv file with all timesheets created and saved
    def self.generate_csv(file)
        CSV.open('report.csv', 'a', headers: headers, write_headers: true) do |csv|
            file.each do |hash|
                hash[:timesheets].each do |hash2|
                    csv << hash2.values
                end
            end
        end
        puts "\n File 'report.csv' created successfully! \n".bg(:yellow).black
    rescue FileError => e
        @@prompt.error(e.message)
    end
end
