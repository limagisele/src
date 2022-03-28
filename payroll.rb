require 'date'
require 'time'
require 'json'
require 'csv'

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

    def initialize(start, finish, leave, time)
        @timesheet = {
          start_time: start,
          finish_time: finish,
          working_hours: (finish - start) / 3600,
          leave_type: leave,
          leave_time: time
        }
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

    def self.find_employee(id, password)
        found_employee = @@list_of_employees.find { |person| person.id == id && person.password == password }
        raise(InvalidUserError) if found_employee.nil?

        return found_employee
    end
end

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

# Identify if timesheet already exists and return its index position
def timesheet_index(user_time, timesheet, timesheet_time)
    day = user_time.day.to_s
    index = timesheet.find_index { |elem| elem[timesheet_time][8..9] == day }
    return index
end

employees = JSON.load_file('employees.json', symbolize_names: true)
employees.each { |person| Employee.list_of_employees << Employee.new(person[:name], person[:id], person[:password]) }

puts "Welcome to the Alternative Payroll Program"
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
# Identify employee's timesheets from the file

continue = true
while continue
    puts "What would you like to do?"
    puts "1. Create new timesheet, 2. Edit existing timesheet, 3. Exit"
    print "Please type 1, 2 or 3: "
    option = gets.chomp

    case option
    when "1"
        begin
            timesheet_file = JSON.load_file('timesheets.json', symbolize_names: true)
            user_timesheet = timesheet_file.find { |employee| employee[:id] == user.id }
            Timesheet.date_time_prompt('start date', 'DD.MM.YYYY')
            start_date = Timesheet.date
            Timesheet.date_time_prompt('start time', '24h format - HH:MM')
            start_time = Timesheet.time(start_date)

            # Check if a timesheet for the date entered already exists
            unless timesheet_index(start_time, user_timesheet[:timesheets], :start_time).nil?
                puts "Timesheet already exists for this date."
                puts "Please choose a different date or select 'Edit existing timesheet' on the menu."
                next
            end

            Timesheet.date_time_prompt('end date', 'DD.MM.YYYY')
            end_date = Timesheet.date
            Timesheet.date_time_prompt('finish time', '24h format - HH:MM')
            finish_time = Timesheet.time(end_date)
            raise(InvalidDateError) if start_date > end_date
            raise(InvalidTimeError) if start_time >= finish_time

            print "Do you have any leave to enter for this timesheet? (Y/N) "
            input = gets.chomp.downcase
            leave_taken = if input.include?("y")
                PayableLeave.leave
                          else
                ["N/A", 0]
                          end
            system "clear"
            Timesheet.display_timesheet(user.name, start_time, finish_time, leave_taken)
            input2 = gets.chomp.downcase
            next unless input2.include?("y")

            # Create new timesheet for the user and add into array of timesheets
            user.timesheets << Timesheet.new(start_time, finish_time, leave_taken[0], leave_taken[1])

            # Update user's timesheets in the JSON file
            user_timesheet[:timesheets] << user.timesheets[-1].timesheet
            # Save change into JSON file
            File.write('timesheets.json', JSON.pretty_generate(timesheet_file))
            puts "Timesheet saved successfully!"
        rescue InvalidDateError, InvalidTimeError => e
            puts e.message
            retry
        end
    when "2"
        begin
            timesheet_file = JSON.load_file('timesheets.json', symbolize_names: true)
            user_timesheet = timesheet_file.find { |employee| employee[:id] == user.id }
            Timesheet.date_time_prompt('start date', 'DD.MM.YYYY')
            start_date = Timesheet.date
            Timesheet.date_time_prompt('start time', '24h format - HH:MM')
            start_time = Timesheet.time(start_date)

            # Check if a timesheet for the date entered already exists
            index = timesheet_index(start_time, user_timesheet[:timesheets], :start_time)
            if index.nil?
                puts "Timesheet does not exist for this date."
                puts "Please choose a different date or select 'Create new timesheet' on the menu."
                next
            end

            Timesheet.date_time_prompt('end date', 'DD.MM.YYYY')
            end_date = Timesheet.date
            Timesheet.date_time_prompt('finish time', '24h format - HH:MM')
            finish_time = Timesheet.time(end_date)
            raise(InvalidDateError) if start_date > end_date
            raise(InvalidTimeError) if start_time >= finish_time

            print "Do you have any leave to enter for this timesheet? (Y/N) "
            input = gets.chomp.downcase
            leave_taken = if input.include?("y")
                PayableLeave.leave
                          else
                ["N/A", 0]
                          end
            system "clear"
            Timesheet.display_timesheet(user.name, start_time, finish_time, leave_taken)
            input2 = gets.chomp.downcase
            next unless input2.include?("y")

            # Change timesheet for the user and add into array of timesheets
            user.timesheets << Timesheet.new(start_time, finish_time, leave_taken[0], leave_taken[1])
            # Update user's timesheets in the JSON file
            user_timesheet[:timesheets][index] = user.timesheets[-1].timesheet
            # Save change into JSON file
            File.write('timesheets.json', JSON.pretty_generate(timesheet_file))
            puts "Timesheet saved successfully!"
        rescue InvalidDateError, InvalidTimeError => e
            puts e.message
            retry
        end
    when "3"
        continue = false
    end
end