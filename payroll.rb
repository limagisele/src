require 'date'
require 'time'
require 'json'
require 'csv'

# Includes list of leave paycodes and method to get leave from user
module PayableLeave
    @@leave = ["annual", "bereavement", "long service", "parental", "public holiday", "sick", "unpaid"]

    def self.display_leave_type
        @@leave.each { |leave_type| print "#{leave_type.capitalize} / " }
    end

    def self.leave
        puts "Please choose one of the options below:"
        PayableLeave.display_leave_type
        puts "\n"
        print "Type here your leave: "
        input = gets.chomp.downcase
        input.slice!(" leave")
        print "How many MINUTES are you using for this leave? "
        minutes = gets.strip.to_i
        raise(InvalidLeaveError) if input.nil? || !@@leave.include?(input)

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

# Error raised if leave type does not exist or time is not in the right format
class InvalidLeaveError < StandardError
    def message
        return "Leave type entered does not exist and/or time (minutes) is not correct!"
    end
end

# Create instances of timesheet everytime user creates a new timesheet entry
class Timesheet
    attr_accessor :timesheet

    @@timesheet_file = JSON.load_file('timesheets.json', symbolize_names: true)

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

    def self.date
        begin
            input = gets.strip
            date = Date.parse(input)
            raise(InvalidDateError) if date.cweek != Date.today.cweek || input.empty?
        rescue ArgumentError
            raise(InvalidDateError)
        end
        return date
    end

    def self.time_casting
        input = gets.strip.split(/:/)
        # "08" and "09" cannot be casted to Integer so need to delete prefix "0"
        new_input = input.map { |number| number.delete_prefix("0") }
        raise(InvalidTimeError) if new_input.empty? || new_input.include?('.')

        return new_input
    end

    def self.time(date)
        begin
            input = Timesheet.time_casting
            time = Time.new(date.year, date.month, date.day, Integer(input[0]), Integer(input[1]), 0)
        rescue ArgumentError
            raise(InvalidTimeError)
        end
        return time
    end

    def self.date_time_prompt(period, format_example)
        print "Please enter the #{period.upcase} of your entry (#{format_example.upcase}): "
    end

    def self.display_timesheet(name, start, finish, leave)
        puts "Please confirm if timesheet below is correct:"
        puts "#{name.capitalize}'s New Timesheet"
        puts "-" * 45
        puts "Start: #{start.strftime('%d.%m.%Y -> %H:%M')}"
        puts "Finish: #{finish.strftime('%d.%m.%Y -> %H:%M')}"
        puts "Leave applied: #{leave[0]} leave -> #{leave[1]} minutes"
        puts "-" * 45
        print "Is data entered correct? (Y/N)? "
    end
end

# Create instances of employee with all info required for payroll
class Employee
    include PayableLeave
    attr_reader :name, :id, :password
    attr_accessor :timesheets

    @@list_of_employees = []

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
        index = timesheet.find_index { |elem| elem[timesheet_time][8..9] == day }
        return index
    end

    # Validate date and time entered by the user
    def self.validate_date
        Timesheet.date_time_prompt('start date', 'DD.MM.YYYY')
        start_date = Timesheet.date
        Timesheet.date_time_prompt('start time', '24h format - HH:MM')
        start_time = Timesheet.time(start_date)
        Timesheet.date_time_prompt('end date', 'DD.MM.YYYY')
        end_date = Timesheet.date
        raise(InvalidDateError) if start_date > end_date

        Timesheet.date_time_prompt('finish time', '24h format - HH:MM')
        finish_time = Timesheet.time(end_date)
        raise(InvalidTimeError) if start_time >= finish_time
        return start_time, finish_time
    end

    # Add leave into timesheet
    def self.add_leave(user, start_time, finish_time)
        print "Do you have any leave to enter for this timesheet? (Y/N) "
        input = gets.chomp.downcase
        leave_taken = if input.include?("y")
                        PayableLeave.leave
                      else
                        ["N/A", 0]
                      end
        system "clear"
        # Ask for user's confirmation on the new timesheet displayed on the terminal
        Timesheet.display_timesheet(user.name, start_time, finish_time, leave_taken)
        input2 = gets.chomp.downcase
        return leave_taken, input2
    end

    # Update user's timesheets in the JSON file
    def self.save_file(user, start_time, finish_time, leave_taken)
        user.timesheets << Timesheet.new(start_time, finish_time, leave_taken[0], leave_taken[1])
        yield
        File.write('timesheets.json', JSON.pretty_generate(Timesheet.timesheet_file))
        puts "Timesheet saved successfully!"
    end

    # Create a new timesheet
    def self.add_timesheet(user, timesheet, timesheet_time)
        start_time, finish_time = validate_date
        p start_time
        p finish_time
        index = timesheet_index(start_time, timesheet, timesheet_time)
        unless index.nil?
            puts "Timesheet already exists for this date."
            puts "Please choose a different date or select 'Edit existing timesheet' on the menu."
            return
        end

        leave_taken, input2 = add_leave(user, start_time, finish_time)
        return unless input2.include?("y")

        save_file(user, start_time, finish_time, leave_taken) { timesheet << user.timesheets[-1].timesheet }
    rescue InvalidDateError, InvalidTimeError => e
        puts e.message
        retry
    end

    # Update an existing timesheet
    def self.update_timesheet(user, timesheet, timesheet_time)
        start_time, finish_time = validate_date
        p start_time
        p finish_time
        index = timesheet_index(start_time, timesheet, timesheet_time)
        if index.nil?
            puts "Timesheet does not exist for this date."
            puts "Please choose a different date or select 'Create new timesheet' on the menu."
            return
        end

        leave_taken, input2 = add_leave(user, start_time, finish_time)
        return unless input2.include?("y")

        save_file(user, start_time, finish_time, leave_taken) { timesheet[index] = user.timesheets[-1].timesheet }
    rescue InvalidDateError, InvalidTimeError => e
        puts e.message
        retry
    end
end

# Upload employees json file and create instances of Employee
employees = JSON.load_file('employees.json', symbolize_names: true)
employees.each { |person| Employee.list_of_employees << Employee.new(person[:name], person[:id], person[:password]) }

puts "Welcome to the Alternative Payroll Program"
# User signin
begin
    print "Please enter your employee ID: "
    user_id = gets.chomp.to_i
    print "Please enter your password: "
    user_code = gets.chomp
    user = Employee.find_employee(user_id, user_code)
rescue InvalidUserError => e
    system "clear"
    puts e.message
    retry
end
system "clear"
puts "Hello, #{user.name.capitalize}!"

continue = true
while continue
    # Locate employee's timesheets in the file and reload it
    file = Timesheet.timesheet_file
    user_timesheet = file.find { |employee| employee[:id] == user.id }
    puts "What would you like to do?"
    puts "1. Create new timesheet, 2. Edit existing timesheet, 3. Manager's report 4. Exit"
    print "Please type 1, 2 or 3: "
    option = gets.chomp
    case option
    when "1"
        # if user is manager
        # ask for which user to create timesheet for
        # Employee.add_timesheet(user, user_timesheet[:timesheets], :start_time)

        Employee.add_timesheet(user, user_timesheet[:timesheets], :start_time)
    when "2"
        Employee.update_timesheet(user, user_timesheet[:timesheets], :start_time)
    when "4"
        continue = false
    end
end
