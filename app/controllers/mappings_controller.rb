class MappingsController < ApplicationController
  before_action :set_mapping, only: [:edit, :update]

  # GET /mappings/1/edit
  def edit
  end

  # PATCH/PUT /mappings/1
  # PATCH/PUT /mappings/1.json
  def update
    respond_to do |format|
      if @mapping.update(mapping_params)
        format.html { redirect_to edit_book_chapter_path(@mapping.chapter.book, @mapping.chapter), notice: 'Mapping was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mapping
      @mapping = Mapping.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mapping_params
      params.require(:mapping).permit(:index_term, :page_id, :comment)
    end
end
