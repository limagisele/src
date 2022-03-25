require './payroll'

describe Timesheet do
    describe '#date' do
        it 'returns a valid date from user input' do
            allow(Timesheet).to receive(:gets).and_return('26/03.2022')
            expect(Timesheet.date).to eq (Date.parse('2022-03-26'))
        end
        it 'returns InvalidDateError if date outside current week' do
            allow(Timesheet).to receive(:gets).and_return('20/03.2022')
            expect { Timesheet.date }.to raise_error(InvalidDateError)
        end
        it 'returns InvalidDateError if user input is not a date' do
            allow(Timesheet).to receive(:gets).and_return('abcd.hah.hgh')
            expect { Timesheet.date }.to raise_error(InvalidDateError)
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

