require 'date'
require 'time'
require 'json'

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
        return "Time entered is not in the right format!"
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
    def initialize(start, finish, leave, time)
        @timesheet = { start_time: start, finish_time: finish, leave_type: leave, leave_time: time }
    end

    def self.date
        begin
            print "Please enter the date of for your entry: "
            input = gets.strip
            date = Date.parse(input)
            raise(InvalidDateError) if date.cweek != Date.today.cweek || input.empty?
        rescue ArgumentError
            raise(InvalidDateError)
        end
        return date
    end

    def self.time(date)
        begin
            input = gets.strip.split(/:/)
            raise(InvalidTimeError) if input.empty? || input.include?(':')

            time = Time.new(date.year, date.month, date.day, Integer(input[0]), Integer(input[1]), 0)
        rescue ArgumentError
            raise(InvalidTimeError)
        end
        return time
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

# Include list of leave paycodes
module PayableLeave

    @@leave = ["sick", "annual", "bereavement", "unpaid", "parental", "long service", "public holiday"]

    def self.leave
        print "Please enter type of leave: "
        input = gets.chomp.downcase
        input.slice!(" leave")
        print "How many minutes are you using for this leave? "
        minutes = gets.strip.to_i
        raise(InvalidLeaveError) if input.nil? || !@@leave.include?(input)

        return input, minutes
    end
end

employees = JSON.load_file('employees.json', symbolize_names: true)
employees.each { |person| Employee.list_of_employees << Employee.new(person[:name], person[:id], person[:password]) }

# puts "Welcome to the Alternative Payroll Program"
# begin
#     print "Please enter your employee ID: "
#     username = gets.chomp.to_i
#     print "Please enter your password: "
#     password = gets.chomp
#     user = Employee.find_employee(username, password)
# rescue InvalidUserError => e
#     system "clear"
#     puts e.message
#     retry
# end
# system "clear"
# puts "Hello, #{user.name}!"

# continue = true
# while continue
#     puts "What would you like to do with your timesheet today?"
#     puts "1. Add new entry, 2. Edit existing timesheet, 3. Exit"
#     print "Type 1, 2 or 3: "
#     option = gets.chomp
    
#     case option
#     when "1"

#     when "2"

#     when "3"
#         continue = false
#     end
# end

# date = Date.parse("26.03.2022")
# p time = Time.new(date.year, date.month, date.day, 20, 30, 0 )
# p time2 = Time.new(date.year, date.month, date.day, 23, 30, 0 )
# p (time2 - time) / 3600
# puts time.strftime("%H:%M")
# puts time.strftime("%d/%m/%Y")
