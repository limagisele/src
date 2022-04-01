require 'date'
require 'time'
require 'json'
require 'tty-prompt'
require 'rainbow/refinement'
using Rainbow

require './classes/employee'
require './classes/errors'

# Create instances of timesheet everytime user creates a new timesheet entry
class Timesheet
    attr_accessor :timesheet

    @@prompt = TTY::Prompt.new(interrupt: :exit)

    def initialize(name, id, start, finish, leave, time)
        @timesheet = {
          name: name,
          id: id,
          start_time: start,
          finish_time: finish,
          working_hours: (finish - start) / 3600,
          leave_type: leave,
          leave_time: time
        }
    end

    def self.timesheet_file
        return @@timesheet_file
    end

    # Check if date entered is valid and within the current week
    def self.date(period)
        begin
            input = @@prompt.ask("Enter #{period.underline} (DD.MM.YYY):", required: true)
            date = Date.parse(input)
            raise(InvalidDateError) if date.cweek != Date.today.cweek
        rescue ArgumentError
            raise(InvalidDateError)
        end
        return date
    end

    # Validate date and time entered by the user
    def self.validate_date
        start_date = date('start date')
        start_time = time(start_date, 'start time')
        finish_time = time(start_date, 'finish time')
        raise(InvalidTimeError) if start_time >= finish_time

        return start_time, finish_time
    end

    # "08" and "09" cannot be casted to Integer so need to delete prefix "0"
    def self.time_casting(period)
        input = @@prompt.ask("Enter #{period.underline} (HH:MM - 24H):", required: true).split(/:/)
        new_input = input.map { |number| number.delete_prefix("0") }
        raise(InvalidTimeError) if new_input.include?('.')

        return new_input
    end

    # Get star and finish times from the user
    def self.time(date, period)
        begin
            input = time_casting(period)
            time = Time.new(date.year, date.month, date.day, Integer(input[0]), Integer(input[1]), 0)
        rescue ArgumentError
            raise(InvalidTimeError)
        end
        return time
    end

    def self.display_timesheet(start, finish, leave)
        puts "Start: #{start.strftime('%d.%m.%Y -> %H:%M').bright.green}"
        puts "Finish: #{finish.strftime('%d.%m.%Y -> %H:%M').bright.green}"
        puts "Leave applied: #{leave[0].bright.green} leave -> #{leave[1].to_s.bright.green} minutes"
    end

    # Show created timesheet to the user for confirmation
    def self.template(name, start, finish, leave)
        puts " #{name}'s New Timesheet ".underline.bg(:antiquewhite).black
        puts "-" * 40
        display_timesheet(start, finish, leave)
        puts "-" * 40
    end
end
