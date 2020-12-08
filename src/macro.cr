module Internationalize
  
  # Translation functions.
  extend self

  macro t(original, name = nil)
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
      # From {{original.id}} at {{original.filename.id}}:{{original.line_number}}
      {{ %Q[translate("#{native.id}", #{expressions.id}, :#{name.id.stringify.gsub(/^"|"$/, "")})].id }}
        
    {% elsif original.class_name == "StringLiteral" %}
      {% native = original; expressions = nil %}
    {% else %}
      {% raise "t(#{original}) at #{original.filename.id}:#{original.line_number}: the argument must be a literal string, not a variable or expression." %}
    {% end %}
    {% name ||= native %}
    {{ comment = "# From #{original} at #{original.filename.id}:#{original.line_number}" }}
    translate({{native.id.stringify}}, {{expressions}}, :{{name.id.stringify.gsub(/^"|"$/, "")}})
    {% if flag?(:"emit-translation-strings") %}
      {% puts comment %}
      {% puts %Q[:#{name.id.stringify.gsub(/^"|"$/, "")} = { #{native}, :#{original.filename}, #{original.line_number} }].id %}
    {% end %}
  end
end
