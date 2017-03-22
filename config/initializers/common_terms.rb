# download 90 most common words
# words = (1..90).map do |i|
#   result = Net::HTTP.get(URI.parse("http://www.wordcount.org/dbquery.php?toFind=#{i}&method=SEARCH_BY_INDEX"))
#   result = result.split('&')
#   result[4].gsub('word0=', '')
# end
# p words

$common_terms = ["of", "and", "to", "a", "in", "that", "it", "is", "was", "i",
  "for", "on", "you", "he", "be", "with", "as", "by", "at", "have", "are",
  "this", "not", "but", "had", "his", "they", "from", "she", "which", "or",
  "we", "an", "there", "her", "were", "one", "do", "been", "all", "their",
  "has", "would", "will", "what", "if", "can", "when", "so", "no", "said",
  "who", "more", "about", "up", "them", "some", "could", "him", "into", "its",
  "then", "two", "out", "time", "like", "only", "my", "did", "other", "me",
  "your", "now", "over", "just", "may", "these", "new", "also", "people", "any",
  "know", "very", "see", "first", "well", "after", "should", "than", "where"]
