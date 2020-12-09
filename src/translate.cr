module I18n
  def self.translate(native : String, arguments : Array|Nil, name : String, tag)
    pattern = /^([^\$]*)?(\$([\$0-9]))(.*)?$/
    string = nil
    if (t = Translations[tag]?)
      if (translation = t[name]?)
        string = translation.first
      end
    end
    string = native if string.nil?

    String.build do |output|
      substring = string
      loop do
        match = pattern.match(substring)
        if match
          # Output the leading portion before any $.
          output << match[1]

          # This is the character after $.
          digit_or_dollar = match[3]

          # This is the trailing portion of the string, and may contain
          # additional $ for arguments.
          substring = match[4]

          if digit_or_dollar == "$"
            output << "$"
          else
            # Output the argument.
            num = digit_or_dollar.to_i
            if arguments.nil? || num > arguments.size
              raise IndexError.new "Translation string #{string.inspect} " \
               "names argument $#{num}, out of range, arguments are " \
               "#{arguments.inspect}."
            end
            output << arguments[num].to_s
          end
        else
          # No $ in the substring, just output the whole thing.
          output << substring
          break
        end
      end
    end
  end
end
