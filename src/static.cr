module I18n
  Translations = {} of String => Hash(String, Tuple(String, Array(String)|Nil, Array(Tuple(String, Int32))))

  {% if flag?(:"emit-translation-strings") %}
    private Strings = {} of String => Tuple(String, Array(String)|Nil, Array(Tuple(String, Int32)))
  {% end %}
end
