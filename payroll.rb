require 'date'
require 'time'
require 'json'
require 'csv'
require 'tty-prompt'
require 'rainbow/refinement'
using Rainbow

require './classes/timesheet'
require './classes/employee'
require './classes/report'
require './classes/errors'
require './module/payable_leave'

prompt = TTY::Prompt.new(interrupt: :exit)

# Upload employees json file and create instances of Employee
employees = JSON.load_file('json_files/employees.json', symbolize_names: true)
employees.each { |person| Employee.list_of_employees << Employee.new(person[:name], person[:id], person[:password]) }

puts "\n Welcome to the Alternative Payroll Program \n".blue.bright.underline
# User signin
user = Employee.signin

continue = true
while continue
    # Locate employee's timesheets in the file and reload it
    # Required so a timesheet can be created and edited while the program si still running
    file = JSON.load_file('json_files/timesheets.json', symbolize_names: true)
    user_timesheet = file.find { |employee| employee[:id] == user.id }

    option = prompt.select("What would you like to do?") do |menu|
        menu.enum "."
        menu.choice "Create Timesheet", 1
        menu.choice "Edit Timesheet", 2
        menu.choice "Access Manager's Options", 3
        menu.choice "Exit", 4
    end
    case option
    when 1
        if user_timesheet[:access_level] == "manager"
            Employee.manager_timesheet(file, :start_time) do |worker, timesheet|
                Employee.add_timesheet(worker, timesheet, :start_time, file)
            end
        else
            Employee.add_timesheet(user, user_timesheet[:timesheets], :start_time, file)
        end
    when 2
        if user_timesheet[:access_level] == "manager"
            Employee.manager_timesheet(file, :start_time) do |worker, timesheet|
                Employee.edit_timesheet(worker, timesheet, :start_time, file)
            end
        else
            Employee.edit_timesheet(user, user_timesheet[:timesheets], :start_time, file)
        end
    when 3
        if user_timesheet[:access_level] == "manager"
            input = prompt.select("Select your option:", ["Create Payroll Report", "RESET Timesheet File"])
            case input
            when "Create Payroll Report"
                Report.generate_csv(file)
            when "RESET Timesheet File"
                Report.generate_json
            end
        else
            prompt.error("\nThis option is available to Management only\n")
            next
        end
    when 4
        continue = false
    end
end
