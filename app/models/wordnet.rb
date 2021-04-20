class Wordnet
  def is_common?(term)
    $common_terms.include?(term)
  end
end
