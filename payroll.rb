require 'date'
require 'json'

class InvalidUserError < StandardError
    def message
        return "Wrong ID and/or password!"
    end
end

class Timesheet
    def initialize(date, start, finish, leave, time)
        @timesheet = { date: date, start_time: start, finish_time: finish, leave_type: leave, leave_time: time }
    end

    def get_date
    end

end

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

module PayableLeave
    def paycode
        @leave = ["sick", "annual", "bereavement", "unpaid", "parental", "long service", "public holiday"]
    end
end


# date = Date.parse('2022.02.23')
# puts date
# puts date.cweek

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

