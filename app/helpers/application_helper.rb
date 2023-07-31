module ApplicationHelper
  def page_title(page_title = '')
    base_title = 'Tournament Note'

    page_title.empty? ? base_title : "#{page_title} | #{base_title}"
  end

  def form_error_notification(object)
    if object.errors.any?
      tag.div id: "error_explanation", class: "alert alert-danger" do
        concat tag.h5 pluralize(object.errors.count, "error")
        concat(tag.ul {
          object.errors.full_messages.each do |message|
            concat tag.li message
          end
        })
      end
    end
  end

  # トーナメント、リーグ共通
  def span_tag__status(tournament)
    case tournament.status
    when 'NOT_STARTED'
      tag.span '開始前', class: ["badge border border-main text-main"]
    when 'ONGOING'
      tag.span '進行中', class: ["badge bg-main"]
    when 'FINISHED'
      tag.span '終了', class: ["badge bg-secondary"]
    end
  end

  def team_name(team)
    team ? team['name'].to_s : "(未定)"
  end


  def game(games:, round: 1, gameNo: nil, a_team: nil, b_team: nil)
    if a_team && b_team
      # リーグ戦
      games.find { |game| game["round"] == round && game["a_team_id"] == a_team["id"] && game["b_team_id"] == b_team["id"] }
    else
      # トーナメント戦
      games.find { |game| game["round"] == round && game["gameNo"] == gameNo }
    end
  end

  def a_score(game)
    game ? "#{game["a_score"]} #{game["a_sub_score"]}" : nil
  end

  def b_score(game)
    game ? "#{game["b_score"]} #{game["b_sub_score"]}" : nil
  end

end
