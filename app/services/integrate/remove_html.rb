module Integrate

  class RemoveHtml
    include Interactor

    def call
      context.chapter_data = context.chapter_data.each do |chapter|
        html2text(chapter)
      end
    end

  end

end
