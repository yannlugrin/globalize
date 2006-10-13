string "I love you!" do
  to :de_DE, "Ich liebe Dich!"
  to :sv_SE, "Jag älskar dig!"
  to :sv_FI, "Jag vill ha sprit!"
end

# If the locale is set to sv_FI using this example translation file,
# "I love you!".t will fall back to 'sv' and return "Ge mig öl!".
# So if you are making the site differ british english from american
# english you should define shared phrases as 'en' and the differing
# ones as 'en_US' and 'en_GB'. For example (using Swedish as the
# site's base language):

string "Vackra färger!" do
  to :en_US, "Lovely colors!"
  to :en_GB, "Lovely colours!"
end

string "Jag älskar min Mac." do
  to :en, "I love my Mac."
end

# Try to avoid reusing strings, it's better to use fictional strings
# instead of real ones in one language, because a phrase that can be
# reused in different context in one language can't in another.

string :login_on_the_frontpage_failed do
  to :en, "Login failed!"
  to :sv, "Misslyckad inloggning!"
end

# In this case you would call this as :login_failed_on_the_frontpage.t
# although you can also use "login_failed_on_the_frontpage".t if you
# want to.

# There are also shorter aliases of string and to that you can use
# if you like being less verbose:
str :foo do
  t :es, "Bar"
end
s "You can translate Rails!" do
  t :ru, "Rails can translate you!"
end

str "Jag har x antal böcker hemma." do
  t :sv, "Jag har {%d} hemma.", "inga böcker", "en bok", "två böcker", "%d böcker"
  t :en, "I have {%d} at home.", "no books", "one book", "%d books"
end
