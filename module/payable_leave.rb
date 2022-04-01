require 'tty-prompt'

# Includes list of leave paycodes and method to get leave from user
module PayableLeave
    @leave = ["Annual", "Bereavement", "Long Service", "Parental", "Public Holiday", "Sick", "Unpaid"]
    @prompt = TTY::Prompt.new(interrupt: :exit)

    def self.leave
        input = @prompt.select("Choose type of leave:", @leave)
        minutes = @prompt.ask("How many MINUTES?", required: true) do |q|
            q.validate(/^\d{1,3}\.?\d?$/)
            q.messages[:valid?] = "Invalid entry. Must be valide minutes(000.0)."
        end

        return input, minutes
    end
end
