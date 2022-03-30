require 'date'
require 'time'
require 'json'
require 'csv'
require 'tty-prompt'
require 'rainbow/refinement'
using Rainbow

# Includes list of leave paycodes and method to get leave from user
module PayableLeave
    @@leave = ["Annual", "Bereavement", "Long Service", "Parental", "Public Holiday", "Sick", "Unpaid"]
    @@prompt = TTY::Prompt.new(interrupt: :exit)

    def self.leave
        input = @@prompt.select("Choose type of leave:", @@leave)
        minutes = @@prompt.ask("How many MINUTES?", required: true) do |q|
            q.validate(/^\d{1,3}\.?\d?$/)
            q.messages[:valid?] = "Invalid entry. Must be valide minutes(000.0)."
        end

        return input, minutes
    end
end

# Error raised if user does not exit or password does not match user
class InvalidUserError < StandardError
    def message
        return "Wrong ID and/or password!"
    end
end

# Error raised if date format cannot be converted into Date instance or if it is outside current week
class InvalidDateError < StandardError
    def message
        return "Date entered is invalid and/or outside this week!"
    end
end

# Error raised if time format cannot be converted into Time instance
class InvalidTimeError < StandardError
    def message
        return "Time entered is not valid!"
    end
end

# Create instances of timesheet everytime user creates a new timesheet entry
class Timesheet
    attr_accessor :timesheet

    @@timesheet_file = JSON.load_file('timesheets.json', symbolize_names: true)
    @@prompt = TTY::Prompt.new(interrupt: :exit)

    def initialize(start, finish, leave, time)
        @timesheet = {
          start_time: start,
          finish_time: finish,
          working_hours: (finish - start) / 3600,
          leave_type: leave,
          leave_time: time
        }
    end

    def self.timesheet_file
        return @@timesheet_file
    end

    def self.date(period)
        begin
            input = @@prompt.ask("Enter #{period.underline} (DD.MM.YYY):", required: true)
            date = Date.parse(input)
            raise(InvalidDateError) if date.cweek != Date.today.cweek
        rescue ArgumentError
            raise(InvalidDateError)
        end
        return date
    end

    def self.time_casting(period)
        input = @@prompt.ask("Enter #{period.underline} (HH:MM - 24H):", required: true).split(/:/)
        # "08" and "09" cannot be casted to Integer so need to delete prefix "0"
        new_input = input.map { |number| number.delete_prefix("0") }
        raise(InvalidTimeError) if new_input.include?('.')

        return new_input
    end

    def self.time(date, period)
        begin
            input = time_casting(period)
            time = Time.new(date.year, date.month, date.day, Integer(input[0]), Integer(input[1]), 0)
        rescue ArgumentError
            raise(InvalidTimeError)
        end
        return time
    end

    def self.display_timesheet(name, start, finish, leave)
        puts "#{name.capitalize}'s New Timesheet".underline.bg(:antiquewhite).black.bright
        puts "-" * 40
        puts "Start: #{start.strftime('%d.%m.%Y -> %H:%M').bright.green}"
        puts "Finish: #{finish.strftime('%d.%m.%Y -> %H:%M').bright.green}"
        puts "Leave applied: #{leave[0].bright.green} leave -> #{leave[1].to_s.bright.green} minutes"
        puts "-" * 40
    end
end

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

    # Find an employee matching given id and password
    def self.find_employee(id, password)
        found_employee = @@list_of_employees.find { |person| person.id == id && person.password == password }
        raise(InvalidUserError) if found_employee.nil?

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
        end_date = Timesheet.date('end date')
        raise(InvalidDateError) if start_date > end_date

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
        Timesheet.display_timesheet(user.name, start_time, finish_time, leave_taken)
        input2 = @@prompt.yes?("Confirm timesheet above?")
        return leave_taken, input2
    end

    # Update user's timesheets in the JSON file
    def self.save_file(user, start_time, finish_time, leave_taken)
        user.timesheets << Timesheet.new(start_time, finish_time, leave_taken[0], leave_taken[1])
        yield
        File.write('timesheets.json', JSON.pretty_generate(Timesheet.timesheet_file))
        puts "Timesheet saved successfully!".bg(:yellow).black
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
end

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
puts "Hello, #{user.name.capitalize}!".bright

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
        # if user is manager
        # ask for which user to create timesheet for
        # Employee.add_timesheet(user, user_timesheet[:timesheets], :start_time)

        Employee.add_timesheet(user, user_timesheet[:timesheets], :start_time)
    when 2
        Employee.update_timesheet(user, user_timesheet[:timesheets], :start_time)
    when 4
        continue = false
    end
end
