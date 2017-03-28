class BooksController < ApplicationController
  authorize_resource
  before_action :set_book, only: [:edit, :update, :destroy, :create_index]

  # GET /books
  def index
    @books = Book.all
  end

  # GET /books/new
  def new
    @book = Book.new
  end

  # GET /books/1/edit
  def edit
  end

  def create_index
    threads = []
    documents = {}
    tags_mutex = Mutex.new
    stemmer = Lingua::Stemmer.new(language: 'en')
    wordnet = Wordnet.new

    @book.chapters.each do |chapter|
      text = Net::HTTP.get(URI.parse(chapter.url))
      doc = Nokogiri::HTML(text)
      doc.css('pre').remove
      # p doc.to_s
      text = Html2Text.convert(doc.to_s)
      text = text.gsub!(/[^A-Za-z ]/, '')
      text = text.split(' ')
      text = text.map do |word|
        stemmer.stem(word).downcase
      end

      text = text.select do |word|
        !wordnet.is_common?(word) && !/^[0-9]+$/.match(word) && word.length > 1
      end

      counts = score(text)

      tags_mutex.synchronize { documents[chapter] = counts }
    end

    # raise

    chapters_count = @book.chapters.count
    max_chapters = chapters_count / 4
    # if max_chapters == 0
    #   max_chapters = 2
    # end

    # data = data.map do |chapter, frequencies|
    #   frequencies = frequencies.select do |word, count|
    #     chapter_count = 0
    #     if count > 3
    #       data.each do |_, other_frequency|
    #         if other_frequency[word] > 3
    #           chapter_count += 1
    #         end
    #       end
    #     end
    #     chapter_count < max_chapters
    #   end
    #   [chapter, frequencies]
    # end.to_h


    document_frequency = Hash.new(0)
    documents.each do |chapter, frequencies|
      frequencies.each do |k, v|
        document_frequency[k] += 1
      end
    end

    # ap document_frequency.sort_by {|_key, value| value}.to_h

    inverted_document_frequency = document_frequency.map do |word, count|
      [word, Math.log(chapters_count / count)]
    end.to_h

    # ap all_words.sort_by {|_key, value| value}.to_h

    vectors = documents.map do |chapter, frequencies|
      weighted_frequencies = frequencies.map do |word, frequency|
        weighted_document = inverted_document_frequency[word] * frequency
        [word, weighted_document]
      end.to_h

      [chapter, weighted_frequencies]
    end.to_h

    vectors = vectors.map do |chapter, frequencies|
      new_frequencies = frequencies.select do |word|
        document_frequency[word] > 2
      end.to_h
      [chapter, new_frequencies]
    end.to_h

    # ap vectors.sort_by {|_key, value| value}.to_h
    # vectors.each do |chapter, frequencies|
    #   ap chapter
    #   ap frequencies.sort_by {|_key, value| value}.to_h
    # end

    data = vectors.map do |chapter, frequencies|
      words = frequencies.sort_by {|k,v| v}.reverse.map { |k, v| "#{k} #{v}" }.first(15)
      [chapter, words]
    end.to_h


    Book.transaction do
      data.each do |chapter, words|
        chapter.mappings.clear
        words.each do |word|
          chapter.mappings.create!(index_term: word)
        end
      end
    end
  end

  # POST /books
  def create
    @book = Book.new(book_params)

    respond_to do |format|
      if @book.save
        format.html { redirect_to books_path, notice: 'Book was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /books/1
  def update
    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to books_path, notice: 'Book was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /books/1
  def destroy
    @book.destroy
    respond_to do |format|
      format.html { redirect_to books_url, notice: 'Book was successfully destroyed.' }
    end
  end

  private

  def score(array)
    hash = Hash.new(0)
    array.each { |key| hash[key] += 1 }
    hash
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_book
    @book = Book.includes(:chapters).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def book_params
    params.require(:book).permit(:name, :url)
  end
end
