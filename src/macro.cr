module I18n
    macro finished
      {% if flag?(:"emit-translation-strings") %}
        {% puts "Translations = {" %}
        {% for key, value in Translations %}
          {% puts "  #{key} => #{value}," %}
        {% end %}
        {% puts "} of String => Tuple(String, Array(String)|Nil, Array(Tuple(String, Int32)))" %}
      {% end %}
    end

  macro t(original, name = nil, exp = nil)
    {% if original.class_name == "StringInterpolation" %}
      {% expressions = [] of StringLiteral %}
      {% native = "" %}
      {% count = 0 %}
      {% for e, index in original.expressions %}
        {% if e.class_name == "StringLiteral" %}
          {% native += e.gsub(/\$([0-9])/, "$$\\1") %}
        {% elsif e.class_name == "Call" %}
          {% arguments = e.args %}
          {% if e.named_args %}
            {% arguments += e.named_args %}
          {% end %}
          {% if e.receiver %}
            {% receiver = "#{e.receiver}.".id %}
          {% else %}
            {% receiver = "" %}
          {% end %}
          {% expressions.push("#{receiver}#{e.name}(#{arguments.splat})".id) %}
          {% native += "$#{count}" %}
          {% count += 1 %}
        {% else %}
          {% raise "#{original} at #{original.filename}:#{original.line_number}: #{e.class_name} in interpolated string." %}
        {% end %}
      {% end %}
    {% elsif original.class_name == "StringLiteral" %}
      {% native = original; expressions = nil %}
    {% else %}
      {% raise "t(#{original}) at #{original.filename.id}:#{original.line_number}: the argument must be a literal string, not a variable or expression." %}
    {% end %}
    {% name = (name ||= native).id.stringify.gsub(/^"|"$/, "") %}
    {% native = native.id.stringify.gsub(/^"|"$/, "") %}
    {% if exp.class_name == "StringLiteral" %}
      {% exp = [exp] %}
    {% elsif exp && exp.class_name != "ArrayLiteral" %}
      {% raise "exp=#{exp} at #{original.filename}:#{original.line_number}: must be a string or array of strings." %}
    {% end %}
    # From {{original}} at {{original.filename.id}}:{{original.line_number}}"
    translate({{native}}, {{expressions}}, {{name}})
    {% if flag?(:"emit-translation-strings") %}
      {% if (t = Translations[name]) == nil %}
        {% Translations[name] = { native, exp, { original.filename, original.line_number } } %}
      {% else %}
        {% if exp != t[1] %}
          {% puts "Warning: combining multiple versions of the same string, with different values of `exp`, at #{original.filename}:#{original.line_number} and #{t.last}. If you want these to be separate, provide different values for `name`." %}
        {% end %}
        {% t.last.push({ original.filename, original.line_number }) %}
      {% end %}
    {% end %}
  end
end
