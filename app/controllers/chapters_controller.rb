class ChaptersController < ApplicationController
  authorize_resource

  before_action :set_book
  before_action :set_chapter, only: [:edit, :update, :destroy]

  # GET /chapters/new
  def new
    @chapter = @book.chapters.new
  end

  # GET /chapters/1/edit
  def edit
  end

  # POST /chapters
  def create
    @chapter = @book.chapters.new(chapter_params)

    respond_to do |format|
      if @chapter.save
        format.html { redirect_to edit_book_path(@book), notice: 'Chapter was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /chapters/1
  # PATCH/PUT /chapters/1.json
  def update
    respond_to do |format|
      if @chapter.update(chapter_params)
        format.html { redirect_to @chapter, notice: 'Chapter was successfully updated.' }
        format.json { render :show, status: :ok, location: @chapter }
      else
        format.html { render :edit }
        format.json { render json: @chapter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chapters/1
  # DELETE /chapters/1.json
  def destroy
    @chapter.destroy
    respond_to do |format|
      format.html { redirect_to chapters_url, notice: 'Chapter was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_book
    @book = Book.find(params[:book_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_chapter
    @chapter = @book.chapters.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def chapter_params
    params.require(:chapter).permit(:url, :name, :check_sum)
  end
end
