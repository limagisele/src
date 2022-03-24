require './payroll'

describe Employee do
    let(:employee) { Employee.new("Mary Smith", 190, 1234) }
    
    it 'can be initialized' do
        expect(employee).to be_instance_of Employee
    end

end