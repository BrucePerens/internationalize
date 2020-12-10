module I18n
  Translations = {} of String => Hash(String, Tuple(String, Array(String)|Nil, Array(Tuple(String, Int32))))

  {% if flag?(:"emit-translation-strings") %}
    # `Strings` is used to build a HashLiteral for macro use that is not part
    # of the compiled program. The macro system doesn't care what type is
    # declared here, and the type `Nil => Nil` will enforce that there is no
    # value built into the compiled version (suggestion of @asterite).
    private Strings = {} of Nil => Nil
  {% end %}
end
