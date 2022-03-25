require './payroll'

describe Timesheet do
    describe '#get_date' do
        it 'returns a valid date from user' do
            allow(Timesheet).to receive(:gets).and_return('2022-02-23')
            expect(Timesheet.get_date).to eq (Date.parse('2022-02-23'))
        end

    end
end

describe Employee do
    describe '#self.employees' do
        it 'returns array of employees' do
            expect(Employee.list_of_employees.length).to eq 3
        end
    end

    describe '#self.find_employee' do
        it 'returns an instance of Employee when exists' do
            found_employee = Employee.find_employee(345, 'abcd')
            expect(found_employee).to be_an_instance_of Employee
        end
        it 'returns InvalidUserError if employee does not exist' do
            expect { Employee.find_employee('john', 'aaa') }.to raise_error(InvalidUserError)
        end
    end
end

