require 'csv'
class Document < ActiveRecord::Base
  serialize :vector
  DIMS = {
      covered_query_term_ratio: 10,
      vector_space_model: 105,
      bm25: 110,
      inlink_number: 128,
      pagerank: 130,
      query_url_click_count: 134,
      url_click_count: 135,
      url_dwell_time: 136
    }
  def sub_vector
    Hash[DIMS.map {|key, dim| [key, self.vector[dim]]}]
  end

  def score(formula)
    calculator = Dentaku::Calculator.new
    begin
      result = calculator.evaluate!(formula, self.sub_vector)
      return result
    rescue
      return 0.0
    end
  end

  def score!(formula)
    calculator = Dentaku::Calculator.new
    calculator.evaluate!(formula, self.sub_vector)
  end

  def self.pairwise(documents)
    result = []
    documents = documents.group_by {|d| d.qid}
    documents.each do |qid, docs|
      docs = docs.group_by {|d| d.grade}
      grades = docs.keys
      grades.each do |grade1|
        grades.each do |grade2|
          if grade1 < grade2
            result += self.get_pairs(docs[grade2], docs[grade1])
          end
        end
      end
    end
    return result
  end

  def self.get_pairs(higher, lower)
    result = []
    higher.each do |h|
      lower.each do |l|
        result << [h, l]
      end
    end
    return result
  end

  def self.to_csv(pairs)
    keys = DIMS.keys.sort_by {|k| DIMS[k]}
    headers = ["pair_id"] + keys.map {|k| "#{k}_better"} + keys.map {|k| "#{k}_worse"}
    CSV.generate(headers: headers, write_headers: true) do |csv|
      pairs.each do |pair|
        csv << (["#{pair.first.id}-#{pair.last.id}"]\
          + keys.map {|k| pair.first.vector[DIMS[k]]} + keys.map {|k| pair.last.vector[DIMS[k]]})
      end
    end
  end
end
