require './payroll'

describe Timesheet do
    let(:file) { JSON.load_file('json_files/timesheets.json', symbolize_names: true) }
    let(:user_timesheet) { file.find { |employee| employee[:id] == 1111 } }

    # Test related to Create and Edit Timesheet features
    # Times entered by user need to be casted to Integer in order to create an instance of Time in #time
    # "08" and "09" cannot be casted to Integer so need to delete prefix "0"
    describe '#time_casting' do
        it 'eliminates prefix 0 from hour and minutes entered by user' do
            expect(Timesheet.time_casting(%w[08 00])).to eq(%w[8 0])
        end
    end

    # Tests related to the Edit Timesheet feature
    # User can only edit a timesheet if there is one saved in the file matching the date entered by the user
    describe '#timesheet_index' do
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
end

describe Employee do
    # Test to confirm employees.json has been made loaded into @list_of_employees
    # as instances of Employee class
    describe '#upload_employees' do
        it 'creates instances of Employee' do
            Employee.upload_employees
            expect(Employee.list_of_employees[0]).to be_an_instance_of Employee
        end
    end

    # Tests to protect the Sign-in feature
    # User needs to match employee ID and password
    # User needs to be an existing instance of Employee class
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
