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

# Upload employees json file and create instances of Employee
employees = JSON.load_file('employees.json', symbolize_names: true)
employees.each { |person| Employee.list_of_employees << Employee.new(person[:name], person[:id], person[:password]) }
prompt = TTY::Prompt.new(interrupt: :exit)
puts "Welcome to the Alternative Payroll Program".blue.bright.underline
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
puts "Hello, #{user.name.capitalize}!".black.bg(:antiquewhite)

continue = true
while continue
    # Locate employee's timesheets in the file and reload it
    file = Timesheet.timesheet_file
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
            worker_id = prompt.ask("Enter required employee's ID?", required: true).to_i
            worker = Employee.find_employee(worker_id)
            worker_timesheet = file.find { |employee| employee[:id] == worker.id }
            puts "Your are now accessing #{worker.name.capitalize}'s timesheet".black.bg(:antiquewhite)
            Employee.add_timesheet(worker, worker_timesheet[:timesheets], :start_time)
        else
            Employee.add_timesheet(user, user_timesheet[:timesheets], :start_time)
        end
    when 2
        Employee.update_timesheet(user, user_timesheet[:timesheets], :start_time)
    when 4
        continue = false
    end
end
