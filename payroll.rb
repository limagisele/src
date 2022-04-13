# Importing required libraries
require 'json'
require 'date'
require 'tty-prompt'
require 'rainbow/refinement'
using Rainbow

require './classes/employee'
require './classes/report'

# Add command line arguments
begin
    if ARGV.include?('-g') || ARGV.include?('--gems')
        File.foreach('Gemfile') do |line|
            puts line unless line.include?('#')
        end
        return
    elsif ARGV.include?('-h') || ARGV.include?("--help")
        file = File.open('text_files/help.txt')
        data = file.read
        puts data
        return
    elsif ARGV.include?('-a') || ARGV.include?("--access")
        file = File.open('text_files/access_level.txt')
        data = file.read
        puts data
        return
    end
rescue FileError => e
        @prompt.error(e.message)
end

# Create instance to use tty-prompt
prompt = TTY::Prompt.new(interrupt: :signal)

# Upload employees json file and create instances of Employee
Employee.upload_employees

# Print welcome message
puts "\n\u{1F553} Welcome to the Alternative Payroll Program \n".blue.bright

begin
    # User signin
    user = Employee.signin

    continue = true
    while continue
        # Reload timesheets.json file
        # Reload is required so a timesheet can be created and edited while the program is still running
        file = JSON.load_file('json_files/timesheets.json', symbolize_names: true)
        # Find employee's timesheet within the file
        user_timesheet = file.find { |employee| employee[:id] == user.id }
        # Display menu to user
        option = prompt.select("What would you like to do?") do |menu|
            menu.enum "."
            menu.choice "Create Timesheet", 1
            menu.choice "Edit Timesheet", 2
            menu.choice "Access Manager's Options", 3
            menu.choice "Exit", 4
        end
        case option
        when 1
            # Manager can create timesheet for any employee
            if user_timesheet[:access_level] == "manager"
                Employee.manager_access(file, :start_time) do |worker, timesheet|
                    Employee.add_timesheet(worker, timesheet, :start_time, file)
                end
            # Other employees can only create their own timesheet
            else
                Employee.add_timesheet(user, user_timesheet[:timesheets], :start_time, file)
            end
        when 2
            # Manager can edit timesheet for any employee
            if user_timesheet[:access_level] == "manager"
                Employee.manager_access(file, :start_time) do |worker, timesheet|
                    Employee.edit_timesheet(worker, timesheet, :start_time, file)
                end
            # Other employees can only edit their own timesheet
            else
                Employee.edit_timesheet(user, user_timesheet[:timesheets], :start_time, file)
            end
        when 3
            # Only managers can access report and file options
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
rescue Interrupt
    prompt.error("\nProgram was interrupted and any unsaved data was potentially lost.\n")
end
