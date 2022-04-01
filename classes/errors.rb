# Error raised if user does not exit or password does not match user
class InvalidUserError < StandardError
    def message
        return "\nWrong ID and/or password!\n"
    end
end

# Error raised if date format cannot be converted into Date instance or if it is outside current week
class InvalidDateError < StandardError
    def message
        return "\nDate entered is invalid and/or outside this week!\n"
    end
end

# Error raised if time format cannot be converted into Time instance
class InvalidTimeError < StandardError
    def message
        return "\nTime entered is not valid!\n"
    end
end

# Error raised if file cannot be uploaded or created
class FileError < StandardError
    def message
        return "\nFile could not be loaded/created!\n"
    end
end

# Error raised when user try to create a timesheet and there is one already in place for that date
class AddTimesheetError < StandardError
    def message
        return "\nTimesheet already exists for this date.\n"
    end
end

# Error raised when user try to edit a timesheet and there is none in place for that date
class EditTimesheetError < StandardError
    def message
        return "\nThere is no timesheet for this date yet.\n"
    end
end
