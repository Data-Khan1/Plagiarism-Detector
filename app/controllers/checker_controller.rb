class CheckerController < ApplicationController
before_action :authenticate_user!
  require 'pdf-reader'

  def index
  end

  def check
    text1 = extract_text(params[:text1], params[:text_file_1])
    text2 = extract_text(params[:text2], params[:text_file_2])

    @similarity_percentage = jaccard_similarity(text1, text2)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace('result', partial: 'result') }
      format.html { render :index }
    end
  end

  private

  def extract_text(text_input, text_file)
    text_input.presence || (text_file && read_text_from_file(text_file)) || ''
  end

  def read_text_from_file(file)
    if file.content_type == 'application/pdf'
      extract_text_from_pdf(file.tempfile.path)
    else
      file.read
    end
  end

  def extract_text_from_pdf(file_path)
    reader = PDF::Reader.new(file_path)
    text = ''
    reader.pages.each { |page| text << page.text }
    text
  end

  def jaccard_similarity(str1, str2)
    set1, set2 = str1.split(" ").to_set, str2.split(" ").to_set
    union = set1.union(set2)

    union.empty? ? 0 : (set1.intersection(set2).size.to_f / union.size.to_f) * 100
  end
end