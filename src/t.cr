module I18n
  macro t(original, name = nil, exp = nil, add = nil)
    {% if original.class_name == "StringInterpolation" %}
      {% positional = [] of String %}
      {% named = {} of String => String %}
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
          {% positional.push("#{receiver}#{e.name}(#{arguments.splat})".id) %}
          {% native += "$#{count}" %}
          {% count += 1 %}
        {% else %}
          {% raise "#{original} at #{original.filename}:#{original.line_number}: #{e.class_name} in interpolated string." %}
        {% end %}
      {% end %}
      {% if add %}
        {% positional += add %}
      {% end %}
      {% if positional.size == 0 %}
        {% positional = nil %}
      {% end %}
      {% if named.size == 0 %}
        {% named = nil %}
      {% end %}
    {% elsif original.class_name == "StringLiteral" %}
      {% native = original; positional = nil; named = nil %}
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
    I18n.translate({{native}}, {{positional}}, {{named}}, {{name}}, language_tag)
    {% if flag?(:"emit-translation-strings") %}
      {% if (t = Strings[name]) == nil %}
        # `Strings` is `Macros::HashLiteral` data during the macro stage of
        # the compiler. Macros have access to constants and can write them.
        # `Strings` is used here as a global shared between invocations
        # of the `t` macro. It would be built into actual constant data
        # later in the compile, but it is cleared before that stage of the
        # compile in the `finished` macro in `strings.cr`
        {% Strings[name] = { native, exp, [{ original.filename, original.line_number }] } %}
      {% else %}
        {% if exp != t[1] %}
          {% puts "Warning: combining multiple versions of the same string, with different values of `exp`, at #{original.filename}:#{original.line_number} and #{t.last}. If you want these to be separate, provide different values for `name`." %}
        {% end %}
        {% t.last.push({ original.filename, original.line_number }) %}
      {% end %}
    {% end %}
  end
end
