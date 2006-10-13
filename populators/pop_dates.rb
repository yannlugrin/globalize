ENV["RAILS_ENV"] = 'development'
require 'config/environment'
require 'date'
include Multilingual

=begin
files = Dir.glob("D:/projects/temp/old-mlr/lib/multilingual/locales/lang-data/*.rb")
files.each do |fp|
  sections = fp.split '/'
  fn = sections.last
  code, ext = fn.split '.'

  if %w(ar_IQ zh_CN bn_BD).include?(code)
    lg, ct = code.split '_'
    code = lg
  else
#    puts "skipping regular"
    next
  end
=end

lang = Language.pick("he")

#  lang = Language.pick(code)
  if !lang
    puts "ERROR: can't find #{code}"
    next
  end

  lang_id = lang.id

#  str = File.read(fp)
#  eval str

@lang_data = {
  :days => [ 'יום ראשון', 'יום שני', 'יום שלישי', 'יום רביעי', 'יום חמישי', 'יום ששי', 'יום שבת' ],
  :abdays => [ 'יום א\'', 'יום ב\'', 'יום ג\'', 'יום ד\'', 'יום ה\'', 'יום ו\'', 'שבת' ],
  :months => [ 'ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני', 'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר' ],
  :abmonths => [ 'ינו\'', 'פבר\'', 'מרץ', 'אפר\'', 'מאי', 'יונ\'', 'יול\'', 'אוג\'', 'ספט\'', 'אוק\'', 'נוב\'', 'דצמ\'' ]
}

  days = @lang_data[:days]
  days.each_index do |idx|
    key = "#{Date::DAYNAMES[idx]} [weekday]"
    val = days[idx]
    vt = ViewTranslation.pick(key, lang)
    if vt
      vt.update_attribute(:text, [ val ])
    else
      ViewTranslation.create!(:tr_key => key, :language_id => lang_id, :text => [ val ])
    end
  end

  abdays = @lang_data[:abdays]
  abdays.each_index do |idx|
    key = "#{Date::ABBR_DAYNAMES[idx]} [abbreviated weekday]"
    val = abdays[idx]
    vt = ViewTranslation.pick(key, lang)
    if vt
      vt.update_attribute(:text, [ val ])
    else
      ViewTranslation.create!(:tr_key => key, :language_id => lang_id, :text => [ val ])
    end
  end

  months = @lang_data[:months]
  months.each_index do |idx|
    key = "#{Date::MONTHNAMES[idx + 1]} [month]"
    val = months[idx]
    vt = ViewTranslation.pick(key, lang)
    if vt
      vt.update_attribute(:text, [ val ])
    else
      ViewTranslation.create!(:tr_key => key, :language_id => lang_id, :text => [ val ])
    end
  end

  abmonths = @lang_data[:abmonths]
  abmonths.each_index do |idx|
    key = "#{Date::ABBR_MONTHNAMES[idx + 1]} [abbreviated month]"
    val = abmonths[idx]
    vt = ViewTranslation.pick(key, lang)
    if vt
      vt.update_attribute(:text, [ val ])
    else
      ViewTranslation.create!(:tr_key => key, :language_id => lang_id, :text => [ val ])
    end
  end

  puts "updated #{lang.english_name} [id=#{lang_id}]"
  
#end

