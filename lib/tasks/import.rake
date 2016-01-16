require 'csv'
namespace :import do
  desc "Import documents"
  task :documents => :environment do
    filepath = ENV['filepath']
    documents = []
    allvals = {}
    File.open(filepath, "r") do |f|
      while line = f.gets
        ls = line.split(" ").map {|l| l.strip}
        grade = ls[0].to_i
        qid = ls[1].split(":")[1].to_i
        v = {}
        ls[2..-1].each do |l|
          key, val = l.split(":")
          v[key.to_i] = val.to_f
          (allvals[key.to_i] ||= []) << val.to_f
        end
        documents << Document.new(qid: qid, grade: grade, vector: v)
      end
    end

    # normalize and save
    allvals.each {|k, v| allvals[k] = [v.min, v.max]}
    documents.each do |document|
      document.vector.each do |k, v|
        if allvals[k].first != allvals[k].last
          document.vector[k] = (v - allvals[k].first) / (allvals[k].last - allvals[k].first)
        end
      end
      document.save!
    end
  end
end

