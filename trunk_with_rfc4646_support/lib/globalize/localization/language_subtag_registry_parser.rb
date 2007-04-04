require 'yaml'

module Globalize
  class LanguageSubtagRegistry  #:nodoc:
    attr_accessor :entries, :subtags

    def self.parse(file)
      lsr = self.new

      File.open(file, 'r') do |f|
        f.readline #skip date
        registry_data = f.read
        lsr.subtags = registry_data.split(/%%/).collect do |entry|
          subtag_entry = entry.strip
          subtag = subtag_entry.scan(/Subtag: (.*?)\n/).flatten
          subtag_entry.gsub!(/(Subtag: .*?\n)/,"Subtag: '#{subtag}'\n")
          if subtag_entry.match(/(Description: (.*?)\n){2}/)
            descriptions = subtag_entry.scan(/Description: (.*?)\n/).flatten
            subtag_entry.gsub!(/(Description: .*?\n)+/,"Description:\n  - #{descriptions.join("\n  - ")}\n")
          end
          subtag_entry.gsub!(/\n/,"\n ")
        end
      end
      lsr.entries = YAML.load("\n-\n #{lsr.subtags.join("\n-\n ")}\n")
      lsr.entries.shift
      lsr
    end

    def entry_for(tag_or_subtag)
      self.entries.detect {|e| e['Tag'] == tag_or_subtag || e['Subtag'] == tag_or_subtag}
    end

    def description_for(tag_or_subtag)
      case tag_or_subtag
        when String
          entry = self.entries.detect {|e| e['Tag'] == tag_or_subtag || e['Subtag'] == tag_or_subtag}
          return nil unless entry
          entry['Description']
        when Hash
          tag_or_subtag['Description']
        else
          nil
      end
    end

    def has_tag?(tag)
      self.entries.any? {|e| e['Tag'] == tag}
    end

    def has_subtag?(subtag)
      self.entries.any? {|e| e['Subtag'] == subtag}
    end

    def has_language_subtag?(subtag)
      self.entries.any? {|e| e['Type'] == 'language' && e['Subtag'] == subtag}
    end

    def has_script_subtag?(subtag)
      self.entries.any? {|e| e['Type'] == 'script' && e['Subtag'] == subtag}
    end

    def has_region_subtag?(subtag)
      self.entries.any? {|e| e['Type'] == 'region' && e['Subtag'] == subtag}
    end

    def has_variant_subtag?(subtag)
      self.entries.any? {|e| e['Type'] == 'variant' && e['Subtag'] == subtag}
    end

    def has_grandfathered_tag?(tag)
      self.entries.any? {|e| e['Type'] == 'grandfathered' && e['Tag'] == tag}
    end

    def is_redundant_tag?(tag)
      self.entries.any? {|e| e['Type'] == 'redundant' && e['Tag'] == tag}
    end

    def has_preferred_value_for_tag?(tag)
      self.entries.any? {|e| (e['Tag'] == tag) && (e['Preferred-Value'] && !e['Preferred-Value'].empty?)}
    end

    def has_preferred_value_for_subtag?(subtag)
      self.entries.any? {|e| (e['Subtag'] == subtag) && (e['Preferred-Value'] && !e['Preferred-Value'].empty?)}
    end

    def has_preferred_value?(tag_or_subtag)
      has_preferred_value_for_tag?(tag_or_subtag) || has_preferred_value_for_subtag?(tag_or_subtag)
    end

    def preferred_value_for_tag(tag)
      return nil unless has_preferred_value_for_tag?(tag)
      self.entries.detect {|e| e['Tag'] == tag && (e['Preferred-Value'] && !e['Preferred-Value'].empty?)}['Preferred-Value']
    end

    def preferred_value_for_subtag(subtag)
      return nil unless has_preferred_value_for_subtag?(subtag)
      self.entries.detect {|e| e['Subtag'] == subtag && (e['Preferred-Value'] && !e['Preferred-Value'].empty?)}['Preferred-Value']
    end

    def preferred_value(tag_or_subtag)
      return nil unless has_preferred_value?(tag_or_subtag)
      preferred_value_tag = preferred_value_for_tag(tag_or_subtag)
      preferred_value_tag ||=  preferred_value_for_subtag(tag_or_subtag)
    end

    def has_suppress_script?(subtag)
      self.entries.any? {|e| (e['Subtag'] == subtag) && (e['Suppress-Script'] && !e['Suppress-Script'].empty?)}
    end

    def suppress_script(subtag)
      return nil unless has_suppress_script?(subtag)
      self.entries.detect {|e| (e['Subtag'] == subtag)}['Suppress-Script']
    end


    alias_method :subtag? , :has_subtag?
    alias_method :tag? , :has_tag?
    alias_method :language? , :has_language_subtag?
    alias_method :script? , :has_script_subtag?
    alias_method :region? , :has_region_subtag?
    alias_method :variant? , :has_variant_subtag?
    alias_method :grandfathered? , :has_grandfathered_tag?
    alias_method :redundant? , :is_redundant_tag?
    alias_method :preferred? , :has_preferred_value?
    alias_method :preferred_tag? , :has_preferred_value_for_tag?
    alias_method :preferred_subtag? , :has_preferred_value_for_subtag?
    alias_method :preferred , :preferred_value
    alias_method :preferred_tag , :preferred_value_for_tag
    alias_method :preferred_subtag , :preferred_value_for_subtag
    alias_method :suppress? , :has_suppress_script?
    alias_method :suppress , :suppress_script

    def self.valid?(file)
      begin
        parse(file)
      rescue Exception
        return false
      else
        return true
      end
    end

  end
end