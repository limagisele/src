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

# Upload employees json file and create instances of Employee
employees = JSON.load_file('json_files/employees.json', symbolize_names: true)
employees.each { |person| Employee.list_of_employees << Employee.new(person[:name], person[:id], person[:password]) }
prompt = TTY::Prompt.new(interrupt: :exit)
puts "\n Welcome to the Alternative Payroll Program \n".blue.bright.underline
# User signin
begin
    user_id = prompt.ask("What's your employee ID?", required: true).to_i
    user_code = prompt.mask("Enter your password:", required: true)
    user = Employee.find_employee(user_id, user_code)
rescue InvalidUserError => e
    system "clear"
    prompt.error(e.message)
    retry
end
system "clear"
puts "\n Hello, #{user.name}! \n".black.bg(:antiquewhite)

continue = true
while continue
    # Locate employee's timesheets in the file and reload it
    file = JSON.load_file('json_files/timesheets.json', symbolize_names: true)
    user_timesheet = file.find { |employee| employee[:id] == user.id }
    option = prompt.select("What would you like to do?") do |menu|
        menu.enum "."

        menu.choice "Create Timesheet", 1
        menu.choice "Edit Timesheet", 2
        menu.choice "Generate manager's report", 3
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
                Employee.update_timesheet(worker, timesheet, :start_time, file)
            end
        else
            Employee.update_timesheet(user, user_timesheet[:timesheets], :start_time, file)
        end
    when 3
        if user_timesheet[:access_level] == "manager"
            input = prompt.yes?("Generate payroll report?")
            if input == true
                Report.generate_csv(file)
                puts "\n File 'report.csv' created successfully! \n".bg(:yellow).black
            end
        else
            prompt.error("\nThis option is available to Management only\n")
            next
        end
    when 4
        continue = false
    end
end
