class HomeController < ApplicationController
  before_action :get_formula
  def index
    @documents = Document.all
    allpairs = Document.pairwise(@documents)
    try_scoring(allpairs.first)
    @total_pair_count = allpairs.size
    @total_correct_count = allpairs.select {|pair|
      pair.first.score(@formula) > pair.last.score(@formula)}.size
    @pairs = Kaminari::paginate_array(allpairs).page(params[:page]).per(100)
    respond_to do |format|
      format.html
      format.csv { send_data Document.to_csv(allpairs),
        type: 'text/csv', filename: "documents.csv" }
    end
  end

  def download
  end

  private
    def get_formula
      if params[:function]
        @formula = params[:function][:formula]
      else
        @formula = "covered_query_term_ratio"
      end
    end

    def try_scoring(pair)
      begin
        pair.first.score!(@formula)
      rescue NoMethodError
        @error = "Something wrong with your formula"
      rescue => e
        @error = e.to_s
      end
    end
end
