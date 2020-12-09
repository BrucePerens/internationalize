module I18n
  def self.translate(native : String, arguments : Array|Nil, name : String)
    STDERR.puts %Q[translate(#{native.inspect}, #{arguments.inspect}, #{name.inspect})]
  end
end
