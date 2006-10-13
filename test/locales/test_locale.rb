string :all_countries do
  to :en, "All countries"
  to :sv, "Alla länder"
end

string :all_countries_except_norway do
  to :en, "All countries except Norway"
  to :sv, "Alla länder utom Norge"
end

string :countries_with_some_prioritized do
  to :en, "All countries with some prioritized"
  to :sv, "Alla länder med några prioriterade"
end

string :only_a_few_selected_countries do
  to :en, "Only a few selected countries"
  to :sv, "Bara några få utvalda länder"
end

string :same_countries_as_above_with_formal_name do
  to :en, "Same countries as above but with their formal names"
  to :sv, "Samma länder som ovan men med deras formella namn"
end

string :same_countries_as_above_with_swap_parts do
  to :en, "Same countries as above but with swapped parts"
  to :sv, "Samma länder som ovan men som de utläses"
end

string :same_countries_as_above_with_common_name do
  to :en, "Same as above but with their common name"
  to :sv, "Samma som ovan men med deras vanliga namn"
end

string "Title is too long (max is %d characters)" do
  to :sv, "Titeln är för lång (max %d tecken)"
end

s :test_symbol_percent do
  t :sv, "Är %d"
  t :en, "Is %d"
end

str :i_have_some_books_at_home do
  t :sv, "Jag har %P hemma.", "inga böcker", "en bok", "%d böcker"
  t :en, "I have %P at home.", "no books", "one book", "%d books"
end