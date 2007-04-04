module Globalize
  class RFC_4646  #:nodoc:
    attr_accessor :primary, :script, :region, :variants, :extensions, :extension_match, :privateuse, :irregulars, :tag, :lsr

    #ALPHA
    ALPHA = "[a-zA-Z]"

    #DIGIT
    DIGIT = "[0-9]"

    #ALPHADIGIT
    ALPHANUM = "[a-zA-Z0-9]"

    #private use singleton
    X = "[xX]"

    # Other singleton! Rest of singleton
    SINGLETON = "[a-wy-zA-WY-Z0-9]"

    #Group separator -- lenient parsers will use
    S = "[-]"

    #  Now do the components. The structure is slightly different to allow
    # for capturing the right components. The "?:" can be deleted if  someone
    # doesn"t care about capturing.
    #(-[a-z]{3}){0,3}
    #
    EXTLANG = "(#{S}#{ALPHA}{3}){0,3}";# *3("-" 3ALPHA);

    #basic language, e.g. en or english
    #(2*3ALPHA [ extlang ]) / 4ALPHA / 5*8ALPHA
    #LANGUAGE = "(#{ALPHA}{4,8}|(#{ALPHA}{2,3}(#{EXTLANG})*?))"
    #LANGUAGE = "(#{ALPHA}{4,8}|(#{ALPHA}{2,3}(#{EXTLANG})*))"
    LANGUAGE = "(#{ALPHA}{4,8}|(#{ALPHA}{2,3}(#{EXTLANG})))"

    # Script - 4ALPHA
    SCRIPT = "(#{ALPHA}{4})"

    # region - 2ALPHA                 ; ISO 3166 code
  #            / 3DIGIT             ; UN M.49 code
    #e.g. AB, ab, 123
    #  2ALPHA / 3DIGIT
    REGION = "(#{ALPHA}{2}|#{DIGIT}{3})"

    # Helper for variant - which is 5*8alphanum  / (DIGIT 3alphanum)
    VARIANTSUB = "(#{ALPHANUM}{5,8}|#{DIGIT}#{ALPHANUM}{3})"

    #5*8alphanum  / (DIGIT 3alphanum)
    # E.g. abcde, 3abc, 3123
    VARIANT = "(#{VARIANTSUB}(#{S}#{VARIANTSUB})*)"


    # (([a-zA-Z0-9]{5,8}|[0-9][a-zA-Z0-9]{3})([-]([a-zA-Z0-9]{5,8}|[0-9][a-zA-Z0-9]{3}))*)

    # Helper for extension which is singleton 1*("-" (2*8alphanum))
    EXTENSIONSUB =  "(#{S}#{ALPHANUM}{2,8})+"

    # extension singleton 1*("-" (2*8alphanum))
    EXTENSION = "(#{SINGLETON}(#{EXTENSIONSUB})+)"

    #privateuse - ("x"/"X") 1*("-" (1*8alphanum))
    PRIVATEUSE = "(#{X}(#{S}#{ALPHANUM}{1,8})+)"

    # Define certain grandfathered codes, since otherwise the regex is pretty
    # useless.
    # Since these are limited, this is safe even later changes to
    # the registry --
    # the only oddity is that it might change the type of the
    # tag, and thus the results from the capturing groups.
    # http://www.iana.org/assignments/language-subtag-registry
    # Note that these have
    # to be compared case insensitively, requiring (?i) below.
    #
    #
    # grandfathered = """((?i)  en $s GB $s oed  | i $s (?: ami | bnn |
    # default | enochian | hak | klingon | lux | mingo | navajo | pwn | tao |
    # tay | tsu )  | sgn $s (?: BE $s fr | BE $s nl | CH $s de))"""
    #



    #grandfathered - 1*3ALPHA 1*2("-" (2*8alphanum))
    #                   ; grandfathered registration
    #              ; Note: i is the only singleton
    #              ; that starts a grandfathered tag
    # 2006-11-07T20:50:03Z being sidelined. To be replaced by irregulars.
    GRANDFATHERED = "(i([a-zA-Z]{1,2})?)(#{S}(#{ALPHANUM}){2,8}){1,2}"


    #Irregulars - from http://www.iana.org/assignments/language-subtag-registry
    #Grandfathered tags are those registered under RFC 1766 or RFC 3066 whose
    # subtags are not all in the subtag registry.
    # There are two classes of grandfathered tags:
    # 1. Tags which are "well-formed" but for which some subtags are not
    # registered.
    # 2. Tags which are not well-formed and which are only valid as
    # grandfathered tags (which are called "irregular").
    IRREGULARS ="en-GB-oed|i-ami|i-bnn|i-default" +
                "|i-enochian|i-hak|i-klingon|i-lux|" +
                "|i-mingo|i-navajo|i-pwn|i-tao|i-tay|" +
                "i-tsu|sgn-BE-fr|sgn-BE-nl|sgn-CH-de"


    # langtag       = (language
    #               ["-" script]
    #               ["-" region]
    #              #("-" variant)
    #              #("-" extension)
    #               ["-" privateuse])|
    #               [privateuse]|
    #               [irregulars]
    LANGTAG="^((#{LANGUAGE}(#{S}#{SCRIPT})?(#{S}#{REGION})?(#{S}#{VARIANT})?((#{S}#{EXTENSION})*)(#{S}#{PRIVATEUSE})*)|(#{PRIVATEUSE})*|(#{IRREGULARS}))$"
    #LANGTAG="(#{LANGUAGE}(#{S}#{SCRIPT})?"

    # expr=language
    # expr=script
    #String expr = language + s + variant;

    # ([a-zA-Z]{4,8}|([a-zA-Z]{2,3}([-][a-zA-Z]{3}){0,3}?))[-](([a-zA-Z0-9]{5,8}|[0-9][a-zA-Z0-9]{3})([-]([a-zA-Z0-9]{5,8}|[0-9][a-zA-Z0-9]{3}))*)
    EXPR = "#{LANGUAGE}(#{S}#{SCRIPT})?(#{S}#{REGION})?(#{S}#{VARIANT})?"
    # expr=language+"("+s+script+")?"
    # expr=language+"("+s+script+")?("+s+region+")?("+s+variant+")?("+s+extension+")?("+s+privateuse+")?"
    # expr=root
    # expr=region
    # expr=variant
    # expr=privateuse
    # expr=grandfathered,re.IGNORECASE

    RFC_4646_PATTERN = Regexp.new(LANGTAG, Regexp::IGNORECASE)
    SINGLETON_PATTERN = Regexp.new("-#{RFC_4646::SINGLETON}-")

    LANGUAGE_SUBTAG_REGISTRY_FILE = 'language-subtag-registry'

    def self.parse(tag, validate_against_lsr = false)
      #check for validity
      pattern_matches = tag.match(RFC_4646_PATTERN)
      raise ArgumentError, "bad format for #{tag}, not rfc-4646 compliant" if ((pattern_matches && pattern_matches.captures.compact.all? {|e| e.empty?}) || pattern_matches.nil?)

      #Group 0 -> whole tag
      #
      #Group 1 -> tag with primary + privateuse (not only privateuse or only irregular)
      #
      #Group 2 -> whole primary tag (including extended language tag)
      #Group 3 -> primary tag (only 2/3 char + extended language tags)
      #Group 4 -> primary tag (only all extended language tags)
      #Group 5 -> primary tag (only each extended language tag)
      #
      #Group 6 -> script tag (with hyphen)
      #Group 7 -> script tag (without hyphen)
      #
      #Group 8 -> region tag (with hyphen)
      #Group 9 -> region tag (without hyphen)
      #
      #Group 10 -> all variant tags
      #Group 11 -> all variant tags (without first hyphen)
      #Group 12 -> first variant tag (without hyphen)
      #Group 13 -> rest of variant tags (with first hyphen)
      #Group 14 -> rest of variant tags (without first hyphen)
      #
      #Group 15 -> all extension tags
      #Group 16 -> first extension tag
      #Group 17 -> first extension tag (without first hyphen)
      #Group 18 -> rest of extension tags (with hyphen)
      #Group 19 -> rest of extension tags (with hyphen)
      #
      #Group 20 -> all privateuse tags that come after primary tag (with hyphen)
      #Group 21 -> all privateuse tags that come after primary tag (without hyphen)
      #Group 22 -> all privateuse tags that come after primary tag (without singleton)
      #
      #Group 23 -> all standalone privateuse tags (with first singleton)
      #Group 24 -> all standalone privateuse tags (with first singleton)
      #Group 25 -> all standalone privateuse tags (without first singleton)
      #
      #Group 26 -> all irregulars

      rfc = self.new
      rfc.tag = pattern_matches[1]
      rfc.primary = pattern_matches[3]
      rfc.script = pattern_matches[8]
      rfc.region = pattern_matches[10]
      rfc.variants = pattern_matches[12]
      rfc.variants = rfc.variants.scan(Regexp.new(RFC_4646::VARIANTSUB)).collect {|e| e.first} if rfc.variants
      rfc.extension_match = pattern_matches[16]
      rfc.privateuse = (pattern_matches[22] && !pattern_matches[22].empty?) ? pattern_matches[22] : pattern_matches[24]
      rfc.irregulars = pattern_matches[27]

      if rfc.extension_match && !rfc.extension_match.empty?
        singletons = rfc.extension_match.scan(SINGLETON_PATTERN).collect {|e| e.gsub('-','')}
        raise ArgumentError, "bad format for #{tag}, not rfc-4646 compliant (duplicate singletons)" unless (singletons == singletons.uniq)
        rfc.extensions = pattern_matches[16].scan(Regexp.new(RFC_4646::EXTENSION)).collect {|e| e.first}
      end

      if validate_against_lsr
        rfc.lsr = LanguageSubtagRegistry.parse(File.join(File.dirname(__FILE__), LANGUAGE_SUBTAG_REGISTRY_FILE))
        #TODO
      end

      rfc
    end

    def self.valid?(locale)
      begin
        parse(locale)
      rescue ArgumentError
        return false
      else
        return true
      end
    end

    #For compatibility with RFC_3066 class
    def language
      self.tag
    end

  end
end