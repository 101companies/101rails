class AutocompleteController < ApplicationController

  def index
    # taken fromhttps://github.com/101companies/101worker/blob/master/modules/wiki2triples/helpers/Namespaces.py
    namespaces = [
      'Language',
      'Technology',
      'Concept',
      'Document',
      'Feature',
      'Contribution',
      'Theme',
      'Contributor',
      'Course',
      'Script',
      'Tag',
      'Vocabulary',
      'Service',
      'Term',
      'Namespace'
    ]
    prefix = params[:prefix]
    namespace, title = prefix.split '::'

    if title
      title = title.gsub(/\P{ASCII}/, '')
      render json: Page.where(namespace: namespace, title: /^#{title}/i).pluck(:title)
    else
      render json: Page.where(namespace: namespace).pluck(:title)
    end

  end
end
