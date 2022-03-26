require './payroll'

describe Timesheet do
    describe '#self.date' do
        it 'returns a valid date from user input' do
            allow(Timesheet).to receive(:gets).and_return('26/03.2022')
            expect(Timesheet.date).to eq (Date.parse('2022-03-26'))
        end
        it 'returns InvalidDateError if date outside current week' do
            allow(Timesheet).to receive(:gets).and_return('20/03.2022')
            expect { Timesheet.date }.to raise_error(InvalidDateError)
        end
        it 'returns InvalidDateError if user\'s input is not a date' do
            allow(Timesheet).to receive(:gets).and_return('abcd.hah.hgh')
            expect { Timesheet.date }.to raise_error(InvalidDateError)
        end
        it 'returns InvalidDateError if user\'s input is empty' do
            allow(Timesheet).to receive(:gets).and_return('     ')
            expect { Timesheet.date }.to raise_error(InvalidDateError)
        end
    end
    describe '#self.time' do
        it 'returns a valid Time instance from user input' do
            allow(Timesheet).to receive(:gets).and_return('20:30')
            expect(Timesheet.time(Date.parse('2022-03-26'))).to be_an_instance_of Time
        end
        it 'returns InvalidTimeError if user\'s input cannot be converted to Time' do
            allow(Timesheet).to receive(:gets).and_return('cgfhf')
            expect { Timesheet.time(Date.parse('2022-03-26')) }.to raise_error(InvalidTimeError)
        end
        it 'returns InvalidTimeError if user\'s input is nil' do
            allow(Timesheet).to receive(:gets).and_return('     ')
            expect { Timesheet.time(Date.parse('2022-03-26')) }.to raise_error(InvalidTimeError)
        end
        it 'returns InvalidTimeError if user\'s input is in the format hh.mm' do
            allow(Timesheet).to receive(:gets).and_return('20.30')
            expect { Timesheet.time(Date.parse('2022-03-26')) }.to raise_error(InvalidTimeError)
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
