# I18n: Internationalization for the Crystal Language.
Internationalize strings in your program, including *interpolated* strings.

THIS PACKAGE WILL BE CHECKED IN OVER http://github.com/BrucePerens/i18n when
it's stable.
## Simple Usage
Add to shards.yml
```
    I18n:
      github: BrucePerens/internationalize
      version: "~> 0.5"
```

Use in your project:
```crystal
  require "i18n"
  include I18n

  def language_tag
    # Define this method to return the appropriate IETF or ISO 639 language
    # tag for the user. This would generally come from the
    # HTTP `Accept-Language` header, or a preference entered by the user.
    # This method must be in scope whenever you call the `t` method to
    # translate a string. It can be a method of `self`, a local variable,
    # or a function.
    return "en-US"
  end

  # This is the simplest way to translate a string.
  # The native string will be used as the key in the translation file.
  t "Any string." # => "translated string"

  
  # This translates an *interpolated* string (that's what we call a string
  # containing one or more #{crystal-expression}), giving a name to the
  # string which will be used as a key in the translation file.
  t "An #{1+1} interpolated string", name: "introduce interpolated string"

  # This translates a string, including an explantion to the translator
  # on what the interpolations are for:
  t "A #{user.name} string #{user.city}", exp: ["The user's real name", \
   "The city in which the user lives"]
```

Generate a translation string file, from strings
in your program, using a flag to the Crystal compiler:
```shell
crystal build src/program-name.cr -Demit-translation-strings > src/language.cr
```
This creates the data structure necessary to translate all strings in your
program. Then you will have to fill in the translations. The translation file
will look like this:
```crystal
# Replace "tag" with the appropriate IETF or ISO 639 language tag."
I18n::Translations["tag"] = {
  "A $0 native language $1" => {"A $1 translated language $0", ["The user's real name", "The city in which the user lives"], [{"/home/bruce/Crystal/internationalize/src/test.cr", 9}]},
} of String => Tuple(String, Array(String)|Nil, Array(Tuple(String, Int32)))
```
The key string is a modification of the native language string, with
interpolations replaced by `$0`, `$1`, etc. The value tuple contains the
translated string, with the interpolated arguments potentially in a
different order from the native string, the explanation for the interpolated
parts of the string (if provided), and a list of the filenanes and line-numbers
where the native string occurs in the original source.

The argument to `t` must be a literal string (including interpolated strings),
not a method, expression, or variable. This is because much of the
translation mechanism runs as macros at compile-time.

Strings that are identical except for the interpolated expressions are
combined, and appear *once* in the translation file.
So, these two strings would be combined:
```crystal
a = t "Today's number is #{1+1}!"
a = t "Today's number is #{22.0/7.0}!"
```
This keeps the translator from having to do repeated work, but is sometimes
incorrect. If you want two similar strings to be translated separately, give
them different names, as in:
```crystal
a = t "Today's number is #{1+1}!", name: "Today's number for toddlers"
a = t "Today's number is #{22.0/7.0}!", name: "Today's number for pre-teens"
```
The translation file will be sorted alphabetically by `name`. The default `name`
is a version of the native string with interpolations replaced by `$0`, `$1`,
etc.

The `exp` argument to `t` is an explanation of the interpolated portions of
the string for the translator. If there is only one interpolation in the
string, this can be a string. When there is more than one interpolation, it
should be an array of strings corresponding to each interpolation, as in
```crystal
t "string", exp: ["explantion of first interpolation", "explanation of second interpolation"]
```
The `add` argument is an array of additional interpolated arguments that are
not used in the native-language string, but may be useful in translations. For
example, you may want your translations to include the correct gendered
pronoun for the user:
```crystal
t "string", add: [user.preferred_pronoun(language_tag)]
```
This is sometimes necessary because languages other than English tend to
masculinize sentences if the proper gender pronoun is not known.

When the argument `-Demit-translation-strings` is provided to
`crystal build`,
the compiler will emit a table of all of the strings that are provided
as arguments to `t`.
These are written to `STDOUT` using the `Crystal::Macros#p` method.
This table can be edited into a translation file by the
programmer and translator, and is intended to be used by a program for
filling in such files using machine translation (not yet written).

Languages are commonly referred to using
[IETF language tags](https://en.wikipedia.org/wiki/IETF_language_tag),
or similar tags defined in [ISO 639-3](https://en.wikipedia.org/wiki/ISO_639-3),
but the program does not enforce this. Two common
language tags are "en-US" for English as spoken in the United States, and
"en" for English not distinguishing where it is spoken. Parsing the languages
provided by a web client's `Accept-Language` header into the tags you are
actually using may be complicated.

Translations are defined in a `Hash` called `I18n::Translations`.
This hash contains a hash for each translated language.

A variable, method, or function `language_tag` must exist in the context where
`t` is called, which is or returns a
string for the language tag of the present user. So, this would be of
the form `language_tag = "es"` for Spanish.
`language_tag` need not be global, it may exist
as a function, method or a local variable, as long as it is defined in all
contexts
where `t` is called.

# NOTE: Complications of Translation

At some point you will be askng translators to translate your strings
into different languages. You will probably start with a machine
translation, but these can not be expected to be correct.
There is not an exact one-to-one mapping of words in two languages to the
same meaning. Nor can you expect the order of words in a sentence to remain
the same, since grammars vary widely between languages. Thus, translators may
easily change the order of the interpolated expressions in the translated
string.

To delve briefly into just one of the many differences between languages
that complicate translation:
Many languages like English have no grammatical gender for nouns, while
others gender nouns male and female, male female and neuter, or common
and neuter. Some languages group nouns into animate and inanimate forms,
and some include noun class modifiers which indicate several different
forms of a noun. Such language differences can
require your translator to make assumptions about what you have
written. The default gender is usually male, which can lead to your
translation being masculinized in ways you did not expect.

One way to deal with this is to use the `add:` argument to provide
*additional interpolated expressions*
that are not used in your native language string. For example, these
might contain the user's preferred pronoun (in a version corresponding
to `language_tag`).

This is important because people take offense to being referred to by
a pronoun other than their preferred one,
and this is even a matter of [California Law](https://leginfo.legislature.ca.gov/faces/billNavClient.xhtml?bill_id=201720180SB179) (applying to government agencies rather than citizens).

## To-Do
* Provide a compiler flag to check that a translation exists for all strings
in the program.
* Provide a program to generate machine translations, using a cloud translation
API.
* Provide common facilities, such as number and time format functions,
and functions that translate the user's preferred pronoun, so that whether
the user has set it to "he", "she", "they", "it", or "hir", it is tranlated
appropriately.
* Provide automatic updating of a previously-generated translation file
without loss of information.
* Provide a Crystal version of my old
https://github.com/BrucePerens/i18n-edit, which
allowed Rails users to right-click on a string rendered by a running program,
and directly enter the translation.
