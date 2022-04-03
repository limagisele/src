require 'time'
require './payroll'
require './classes/employee'
require './classes/errors'

describe Timesheet do
    let(:file) { JSON.load_file('json_files/timesheets.json', symbolize_names: true) }
    let(:user_timesheet) { file.find { |employee| employee[:id] == 1111 } }

    # Testing related to the Edit Timesheet feature
    # User can only edit a timesheet if there is one saved in the file matching the date entered by the user
    describe '#find_timesheet' do
        it 'returns array index for the employee\'s timesheet in timesheets.json matching the given date ' do
            start_time = Time.new(2022, 3, 29)
            index = Timesheet.timesheet_index(start_time, user_timesheet[:timesheets], :start_time)
            expect(index).to eq 1
        end
        it 'returns nil if there is no timesheet for the employee on the given date' do
            start_time = Time.new(2022, 4, 3)
            index = Timesheet.timesheet_index(start_time, user_timesheet[:timesheets], :start_time)
            expect(index).to be_nil
        end
    end
    #
    describe '#time' do
        it ''
    end
end

# This test protects the Sign-in feature
# User needs to match employee ID and password
# User needs to be an instance of Employee class
describe Employee do
    describe '#find_employee' do
        it 'returns an instance of Employee when exists' do
            employee = Employee.find_employee(3333, 'xyz456')
            expect(employee).to be_an_instance_of Employee
        end
        it 'returns InvalidUserError if employee does not exist' do
            expect { Employee.find_employee(345, 'abcd') }.to raise_error(InvalidUserError)
        end
        it 'returns InvalidUserError if password is incorrect' do
            expect { Employee.find_employee(3333, 'abcd') }.to raise_error(InvalidUserError)
        end
    end
end
