class Employee
    attr_reader :name, :id, :password

    def initialize(name, id, password)
        @name = name
        @id = id
        @password = password
    end
end

class Worker < Employee
    attr_accessor :timesheets

    @@workers = []

    def initialize(name, id, password)
        super(name, id, password)
        @timesheets = []
    end
end

class Manager < Employee
    def initialize(name, id, password)
        super(name, id, password)
    end

    def report
    end
end

class Timesheet
    include PayableLeave

    def initialize(date)
        @date = date
        @start_time
        @finish_time
        @worked_hours = finish - start
        @leave_taken = {}
    end
    def self.add_time
    end

    def self.edit_time
    end

end

module PayableLeave
    def paycode
        @leave = ["sick", "annual", "bereavement", "unpaid", "parental", "long service", "public holiday"]
    end
    def add_leave
    end
    def edit_leave
    end
end


