module Internationalize
  # Translation functions.
  extend self

  macro t(string, name = nil)
    {% if string.class_name == "StringInterpolation" %}
      {% arguments = [] of StringLiteral %}
      {% s = "" %}
      {% count = 0 %}
      {% for e, index in string.expressions %}
        {% if e.class_name == "StringLiteral" %}
          {% s += e.gsub(/\$([0-9])/, "$$\\1") %}
        {% elsif e.class_name == "Call" %}
          {% a = e.args %}
          {% if e.named_args %}
            {% a += e.named_args %}
          {% end %}
          {% if e.receiver %}
            {% receiver = "#{e.receiver}.".id %}
          {% else %}
            {% receiver = "" %}
          {% end %}
          {% arguments.push("#{receiver}#{e.name}(#{a.splat})".id) %}
          {% s += "$#{count}" %}
          {% count += 1 %}
        {% else %}
          {% raise "#{string} at #{string.filename}:#{string.line_number}: #{e.class_name} in interpolated string." %}
        {% end %}
      {% end %}
      # From {{string.id}} at {{string.filename.id}}:{{string.line_number}}
      {{ %Q[translate("#{s.id}", #{arguments.id}, #{name})].id }}
    {% elsif string.class_name == "StringLiteral" %}
      # From {{string.id}} at {{string.filename.id}}:{{string.line_number}}
      {{ %Q[translate("#{string.id}", nil, #{name})].id }}
    {% else %}
      {% raise "t(#{string}) at #{string.filename}:#{string.line_number}: the argument must be a literal string, not a variable or expression." %}
    {% end %}
  end
end
