module HomeHelper
  def is_success(scores)
    scores.first > scores.last ? " success" : " danger"
  end

  def is_bigger(scores)
    if scores.first > scores.last
      ">"
    elsif scores.first < scores.last
      "<"
    else
      "="
    end
  end
end
