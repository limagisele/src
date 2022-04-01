# Error raised if user does not exit or password does not match user
class InvalidUserError < StandardError
    def message
        return "Wrong ID and/or password!"
    end
end

# Error raised if date format cannot be converted into Date instance or if it is outside current week
class InvalidDateError < StandardError
    def message
        return "Date entered is invalid and/or outside this week!"
    end
end

# Error raised if time format cannot be converted into Time instance
class InvalidTimeError < StandardError
    def message
        return "Time entered is not valid!"
    end
end

# Error raised if file cannot be uploaded or created
class FileError < StandardError
    def message
        return "File could not be loaded/created!"
    end
end
