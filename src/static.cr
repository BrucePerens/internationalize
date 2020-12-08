module I18n
  {% if flag?(:"emit-translation-strings") %}
    private Translations = {} of Symbol => Tuple(String, Array(Tuple(Symbol, Int32)))
  {% end %}
end
