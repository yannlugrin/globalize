module Globalize # :nodoc:
  module CoreExtensions # :nodoc:
		module BidiString
			
			# Automatically adds xhtml markup to force ltr direction, if appropriate
			def bidi_markup
				if Locale.language && Locale.language.direction == 'rtl' && is_ltr?
					'<span dir="ltr">' + self.to_s + '</span>'
				else
					self
				end
			end
			
			def bdo_markup
				if Locale.language && Locale.language.direction == 'rtl' && is_ltr?
					'<bdo dir="ltr">' + self.to_s + '</bdo>'
				else
					self
				end
			end

			def bdo_html
				if Locale.language && Locale.language.direction == 'rtl' && is_ltr?
					"\xe2\x80\xad" + self.to_s + "\xe2\x80\xac"
				else
					self
				end
			end
			
			def bidi_html
				if Locale.language && Locale.language.direction == 'rtl' && is_ltr?
					"\xe2\x80\xaa" + self.to_s + "\xe2\x80\xac"
				else
					self
				end
			end
		
			alias bidi bidi_markup
			
			private
			def is_ltr?
				# only works for hebrew presently
				codepoints = unpack "U*"
				codepoints.each do |cp|
					if cp >= 0x590 && cp <= 0x5ff	# Hebrew Letter
						return false
					end
				end
				true
			end
			
		end
	end
end

