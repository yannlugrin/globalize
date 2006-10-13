class String
  @@plural_forms = {}
  
  PLURAL_FAMILIES = {
    :one => %w(hu ja ko tr),
    :two_germanic => %w(da nl en de no sv et fi el he it pt es eo),
    :two_romanic => %w(fr pt_BR),
    :three_celtic => %w(ga gd),
    :three_baltic_latvian => %w(lv),
    :three_baltic_lithuanian => %w(lt),
    :three_slavic_russian => %w(hr cs ru sk uk),
    :three_slavic_polish => %w(pl),
    :four => %w(sl)
  }
  NPLURAL = {
    :one => 1,
    :two_germanic => 2,
    :two_romanic => 2,
    :three_celtic => 3,
    :three_baltic_latvian => 3,
    :three_baltic_lithuanian => 3,
    :three_slavic_russian => 3,
    :three_slavic_polish => 3,
    :four => 4
  }
  
  def t(locale=nil)
    str, @@plural_forms[str] = Locale.translate(self, locale || Locale.current)
    return str
  end
  def iconv_to(charset)
    return self if charset.downcase == 'utf-8'
    Iconv.new(charset, 'utf-8').iconv(self)
  end
  def iconv_from!(charset)
    return self if charset.downcase == 'utf-8'
    self.replace Iconv.new('utf-8', charset).iconv(self)
  end
  def iconv_from(charset)
    return self if charset.downcase == 'utf-8'
    Iconv.new('utf-8', charset).iconv(self)
  end
  
  # Replace Kconv methods with their faster Iconv equivalents
  # UPDATE: don't! :)
#  def toutf8  ; self                    ; end
#  def toutf16 ; iconv_to('utf-16')      ; end
#  def tojis   ; iconv_to('iso-2022-jp') ; end
#  def tosjis  ; iconv_to('shift-jis')   ; end
#  def toeuc   ; iconv_to('euc-jp')      ; end
  
  def %(args)
    if @substrings.nil?
      @substrings = self.split(/(%P)/)
      @substrings = false if @substrings.size < 2
    end
    return sprintf(self, *args) unless @substrings and @@plural_forms[self]
    
    lang = Locale.current.split('_').first
    
    @substrings.collect do |str|
      if str =~ /^%P$/
        count = args.shift.to_i
        if count == 0
          n = 0
        elsif %w(hu ja ko tr).include?(lang)
          n = 1
        elsif %w(da nl en de no sv et fi fr el he it pt es eo).include?(lang)
          n = (count == 1 ? 1 : 2)
        elsif %w(ga gd).include?(lang)
          n = (count==1 ? 1 : count==2 ? 2 : 3)
        elsif %w(hr cs ru sk uk).include?(lang)
          n = (count%10==1 && count%100!=11 ? 1 : count%10>=2 && count%10<=4 && (count%100<10 || count%100>=20) ? 2 : 3)
        elsif lang == 'lv'
          n = (count%10==1 && count%100!=11 ? 1 : count != 0 ? 2 : 3)
        elsif lang == 'lt'
          n = (count%10==1 && count%100!=11 ? 1 : count%10>=2 && (count%100<10 || count%100>=20) ? 2 : 3)
        elsif lang == 'pl'
          n = (count==1 ? 1 : count%10>=2 && count%10<=4 && (count%100<10 || count%100>=20) ? 2 : 3)
        elsif lang == 'sl'
          n = (count%100==1 ? 1 : count%100==2 ? 2 : count%100==3 || count%100==4 ? 3 : 4)
        else # Fallback to germanic-style
          n = (count == 1 ? 1 : 2)
        end
        
        sprintf @@plural_forms[self][n], count
      else

        sprintf str, *(str.scan(/%(\d+\$)?(-|\+| )?(\.?\d+)?\w\W/).collect { |x| args.shift })
      end
    end.join
  end
end

class Symbol
  def t(locale=nil)
    self.to_s.t locale
  end
  def %(args)
    self.to_s.t % args
  end
end

class Object
  def _(str)
    str.to_s.t
  end
end


if Object.const_defined? :Unicode
  
  class String
    
    def downcase    ; Unicode::downcase(self)                 ; end
    def downcase!   ; self.replace Unicode::downcase(self)    ; end
    def upcase      ; Unicode::upcase(self)                   ; end
    def upcase!     ; self.replace Unicode::upcase(self)      ; end
    def capitalize  ; Unicode::capitalize(self)               ; end
    def capitalize! ; self.replace Unicode::capitalize(self)  ; end
    
    def compose(compat=false)
      if compat
        Unicode::compose_compat(self)
      else
        Unicode::compose(self)
      end
    end
    def compose!(compat=false)
      self.replace compose(compat)
    end
        
    def decompose(compat=false)
      if compat
        Unicode::decompose_compat(self)
      else
        Unicode::decompose(self)
      end
    end
    def decompose!(compat=false)
      self.replace decompose(compat)
    end

    def normalize(compat=false)
      if compat
        Unicode::normalize_KC(self)
      else
        Unicode::normalize_C(self)
      end
    end
    def normalize!(compat=false)
      self.replace normalize(compat)
    end

  end

end


class Time
  alias_method :strftime_orig, :strftime

  def strftime(str)
    str.gsub(/%./) do |m|
      case m
        when '%a'
          Locale.abday(self.wday)
        when '%A'
          Locale.day(self.wday)
        when '%b'
          Locale.abmonth(self.month)
        when '%B'
          Locale.month(self.month)
        else
          strftime_orig(m)
      end
    end
  end
end
