require './payroll'

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
        it 'returns nil if employee does not exist' do
            found_employee = Employee.find_employee('john', 'aaa')
            expect(found_employee).to be_nil
        end
    end

    # describe '#add_timesheet' do
    #     it 'adds new timesheet into timesheets array of a given employee' do
    #         employee = Employee.new('sally', 222, 'xyz')
    #         expect(employee.add_timesheet).to 
end

