module I18n
  # Emit a translation string table when -Demit-translation-strings is set.
  macro finished
    {% if flag?(:"emit-translation-strings") %}
      {% puts %Q[I18n::Translations["tag"] = {] %}

      # Macro array.sort() has a fixed compare method that doesn't work with
      # {key, value} tuples. So here is quicksort in Crystal macro language.
      {% array = Strings.to_a %}
      {% for i in 0...array.size %}
        {% for j in 0...array.size - i - 1 %}
          {% first = array[j] %}
          {% second = array[j + 1] %}
          # Compare the {key, value} tuples. If the first is greater than the
          # second, reverse them.
          {% if first.first > second.first %}
            {% array[j] = second %}
            {% array[j + 1] = first %}
          {% end %}
        {% end %}
      {% end %}

      {% puts %Q[# Replace "tag" with the appropriate IETF or ISO 639 language tag.] %}
      {% for a in array %}
        {% puts "  #{a.first} => #{a.last}," %}
      {% end %}
      {% puts "} of String => Tuple(String, Array(String)|Nil, Array(Tuple(String, Int32)))" %}
      # `Strings` is `HashLiteral` data for the constant. We can clear it
      # before the constant is actually compiled, since we won't need it at
      # runtime.
      {% Strings.clear %}
    {% end %}
  end
end
