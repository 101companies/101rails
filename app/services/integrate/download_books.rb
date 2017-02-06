module Integrate

  class DownloadBooks
    include Interactor

    def call
      chapter_data = Parallel.map(context.book.chapters) do
        chapter.download_content
      end

      chapter_data.each_with_index do |chapter, index|

      end

    end

  end

end
