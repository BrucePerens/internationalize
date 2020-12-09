module I18n
  macro finished
    {% if flag?(:"emit-translation-strings") %}
      {% puts %Q[I18n::Translations["tag"] = {] %}
      {% for key, value in Strings %}
        {% puts "  #{key} => #{value}," %}
      {% end %}
      {% puts "} of String => Tuple(String, Array(String)|Nil, Array(Tuple(String, Int32)))" %}
    {% end %}
  end
end
