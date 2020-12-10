module I18n
  # Emit a translation string table when -Demit-translation-strings is set.
  macro finished
    {% if flag?(:"emit-translation-strings") %}
      {% puts %Q[I18n::Translations["tag"] = {] %}
      # Macro array.sort() won't compare my data structure.
      # So we do our own sort here.
      {% array = Strings.to_a %}
      {% for i_index in 0...array.size %}
        {% for j_index in 0...array.size - i_index - 1 %}
          {% first = array[j_index] %}
          {% second = array[j_index + 1] %}
          {% if first.first > second.first %}
            {% array[j_index] = second %}
            {% array[j_index + 1] = first %}
          {% end %}
        {% end %}
      {% end %}
      {% for a in array %}
        {% puts "  #{a.first} => #{a.last}," %}
      {% end %}
      {% puts "} of String => Tuple(String, Array(String)|Nil, Array(Tuple(String, Int32)))" %}
      {% Strings.clear %}
    {% end %}
  end
end
