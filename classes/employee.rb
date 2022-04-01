require 'json'
require 'csv'
require 'tty-prompt'
require 'rainbow/refinement'
using Rainbow

require './classes/timesheet'
require './classes/errors'
require './module/payable_leave'

# Create instances of employee with all info required for payroll
class Employee
    include PayableLeave
    attr_reader :name, :id, :password
    attr_accessor :timesheets

    @@list_of_employees = []
    @@prompt = TTY::Prompt.new(interrupt: :exit)

    def initialize(name, id, password)
        @name = name
        @id = id
        @password = password
        @timesheets = []
    end

    def self.list_of_employees
        return @@list_of_employees
    end

    # Find an employee with ID and password matching
    # Managers don't require employees' password to access their timesheets
    def self.find_employee(id, password = nil)
        employee = @@list_of_employees.find { |person| person.id == id }
        raise(InvalidUserError) if employee.nil?

        if password.nil?
            found_employee = employee
        else
            found_employee = employee if employee.password == password
            raise(InvalidUserError) if found_employee.nil?
        end
        return found_employee
    end

    # Validate user ID and password
    def self.signin
        user_id = @@prompt.ask("What's your employee ID?", required: true).to_i
        user_code = @@prompt.mask("Enter your password:", required: true)
        user = find_employee(user_id, user_code)
        system "clear"
        puts "\n Hello, #{user.name}! \n".black.bg(:antiquewhite)
        return user
    rescue InvalidUserError => e
        system "clear"
        @@prompt.error(e.message)
        retry
    end

    # Identify if timesheet already exists and return its index position
    def self.timesheet_index(user_time, timesheet, timesheet_time)
        day = user_time.day.to_s
        index = timesheet.find_index { |elem| elem[timesheet_time][8..9].delete_prefix("0") == day }
        return index
    end

    # Add leave into timesheet
    def self.add_leave(user, start_time, finish_time)
        input = @@prompt.yes?("Add any leave for this date?")
        leave_taken = if input == true
                        PayableLeave.leave
                      else
                        ["N/A", 0]
                      end
        system "clear"
        # Ask for user's confirmation on the new timesheet displayed on the terminal
        Timesheet.template(user.name, start_time, finish_time, leave_taken)
        input2 = @@prompt.yes?("Confirm timesheet above?")
        return leave_taken, input2
    end

    # Update user's timesheets in the JSON file
    def self.save_file(user, id, start_time, finish_time, file)
        leave_taken, input2 = add_leave(user, start_time, finish_time)
        return unless input2 == true

        user.timesheets << Timesheet.new(user.name, id, start_time, finish_time, leave_taken[0], leave_taken[1])
        yield
        File.write('json_files/timesheets.json', JSON.pretty_generate(file))
        puts "\n Timesheet saved successfully! \n".bg(:yellow).black
    rescue FileError => e
        @@prompt.error(e.message)
    end

    # Create new timesheet
    def self.add_timesheet(user, timesheet, timesheet_time, file)
        start_time, finish_time = Timesheet.validate_date
        index = timesheet_index(start_time, timesheet, timesheet_time)
        raise(AddTimesheetError) unless index.nil?

        save_file(user, user.id, start_time, finish_time, file) { timesheet << user.timesheets[-1].timesheet }
    rescue InvalidDateError, InvalidTimeError => e
        @@prompt.error(e.message)
        retry
    rescue AddTimesheetError => e
        @@prompt.error(e.message)
    end

    # Edit an existing timesheet
    def self.edit_timesheet(user, timesheet, timesheet_time, file)
        start_time, finish_time = Timesheet.validate_date
        index = timesheet_index(start_time, timesheet, timesheet_time)
        raise(EditTimesheetError) if index.nil?

        save_file(user, user.id, start_time, finish_time, file) { timesheet[index] = user.timesheets[-1].timesheet }
    rescue InvalidDateError, InvalidTimeError => e
        @@prompt.error(e.message)
        retry
    rescue EditTimesheetError => e
        @@prompt.error(e.message)
    end

    # Give a manager access to any timesheet in the file, for any employee
    def self.manager_timesheet(file, start_time)
        worker_id = @@prompt.ask("Enter required employee's ID?", required: true).to_i
        worker = find_employee(worker_id)
        worker_timesheet = file.find { |employee| employee[:id] == worker.id }
        puts "\n You are now accessing #{worker.name}'s timesheet \n".black.bg(:antiquewhite)
        yield(worker, worker_timesheet[:timesheets], start_time)
    rescue InvalidUserError => e
        system "clear"
        @@prompt.error(e.message)
        retry
    end
end
