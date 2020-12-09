module I18n
  {% if flag?(:"emit-translation-strings") %}
    private Translations = {} of String => Tuple(String, Array(String)|Nil, Array(Tuple(String, Int32)))
  {% end %}
end
