require 'date'
require 'time'
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
        unless password.nil?
            found_employee = employee if employee.password == password
            raise(InvalidUserError) if found_employee.nil?
        end
        found_employee = employee

        return found_employee
    end

    # Identify if timesheet already exists and return its index position
    def self.timesheet_index(user_time, timesheet, timesheet_time)
        day = user_time.day.to_s
        index = timesheet.find_index { |elem| elem[timesheet_time][8..9].delete_prefix("0") == day }
        return index
    end

    # Validate date and time entered by the user
    def self.validate_date
        start_date = Timesheet.date('start date')
        start_time = Timesheet.time(start_date, 'start time')
        end_date = start_date
        # end_date = Timesheet.date('end date')
        # raise(InvalidDateError) if start_date > end_date

        finish_time = Timesheet.time(end_date, 'finish time')
        raise(InvalidTimeError) if start_time >= finish_time

        return start_time, finish_time
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
    def self.save_file(user, start_time, finish_time, leave_taken)
        user.timesheets << Timesheet.new(start_time, finish_time, leave_taken[0], leave_taken[1])
        yield
        File.write('timesheets.json', JSON.pretty_generate(Timesheet.timesheet_file))
        puts "\n Timesheet saved successfully! \n".bg(:yellow).black
    end

    # Create a new timesheet
    def self.add_timesheet(user, timesheet, timesheet_time)
        start_time, finish_time = validate_date
        index = timesheet_index(start_time, timesheet, timesheet_time)
        unless index.nil?
            @@prompt.error("Timesheet already exists for this date.")
            @@prompt.say("Try a different date or select 'Edit Timesheet' on the menu below.")
            return
        end

        leave_taken, input2 = add_leave(user, start_time, finish_time)
        return unless input2 == true

        save_file(user, start_time, finish_time, leave_taken) { timesheet << user.timesheets[-1].timesheet }
    rescue InvalidDateError, InvalidTimeError => e
        @@prompt.error(e.message)
        retry
    end

    # Update an existing timesheet
    def self.update_timesheet(user, timesheet, timesheet_time)
        start_time, finish_time = validate_date
        index = timesheet_index(start_time, timesheet, timesheet_time)
        if index.nil?
            @@prompt.error("Timesheet does not exist for this date.")
            @@promp.say("Try a different date or select 'Create Timesheet' on the menu below.")
            return
        end

        leave_taken, input2 = add_leave(user, start_time, finish_time)
        return unless input2 == true

        save_file(user, start_time, finish_time, leave_taken) { timesheet[index] = user.timesheets[-1].timesheet }
    rescue InvalidDateError, InvalidTimeError => e
        @@prompt.error(e.message)
        retry
    end

    def self.manager_timesheet(file, start_time)
        worker_id = @@prompt.ask("Enter required employee's ID?", required: true).to_i
        worker = find_employee(worker_id)
        worker_timesheet = file.find { |employee| employee[:id] == worker.id }
        puts "Your are now accessing #{worker.name.capitalize}'s timesheet".black.bg(:antiquewhite)
        yield(worker, worker_timesheet[:timesheets], start_time)
    end
end
