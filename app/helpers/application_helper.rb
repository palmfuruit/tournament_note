module ApplicationHelper
  def form_error_notification(object, name: nil)
    if object.errors.any?
      tag.div id: "error_explanation", class: "alert alert-danger" do
        concat tag.h5 pluralize(object.errors.count, "error")
        concat tag.p(name, class: "mb-0") if name
        concat(tag.ul {
          object.errors.full_messages.each do |message|
            concat tag.li message
          end
        })
      end
    end
  end

  def default_meta_tags
    {
      site: 'Tournament Note',
      separator: '|',
      title: 'トーナメント表作成/リーグ表作成',
      reverse: true,
      charset: 'utf-8',
      description: 'Tournament Noteは、トーナメント表/リーグ表を作成するWebアプリです。',
      keywords: 'トーナメント,リーグ戦,勝ち抜き戦,総当たり戦,対戦表,ドロー表,無料',
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: 'website',
        url: root_url,
        image: image_url('ogp_v2.png'), # 配置するパスやファイル名によって変更すること
        local: 'ja-JP'
      },
      # Twitter用の設定を個別で設定する
      twitter: {
        card: 'summary_large_image', # Twitterで表示する場合は大きいカードにする
        image: image_url('ogp_v2.png') # 配置するパスやファイル名によって変更すること
      }
    }
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

  def team_uniform(team)
    if team
      if (team["color"].present?) && (team["color"] != "none")
        color = "uniform-" + team["color"]
        tag.i(class: ["fa-solid", "fa-shirt", "fa-lg", color])
      else
        nil
      end
    else
      nil
    end
  end

  def uniform(color)
    color_str = "uniform-" + color
    tag.i(class: ["fa-solid", "fa-shirt", "fa-lg", color_str])
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

  def a_score_num(game)
    game ? "#{game["a_score_num"]}" : nil
  end

  def b_score_num(game)
    game ? "#{game["b_score_num"]}" : nil
  end

  def a_score_str(game)
    game ? "#{game["a_score_str"]}" : nil
  end

  def b_score_str(game)
    game ? "#{game["b_score_str"]}" : nil
  end

  def tournament_owner?(tournament)
    if tournament.elimination?
      elimination = tournament.elimination
      key = "elimination_#{elimination.id}"
      ret = elimination.password.blank? || cookies[key] == elimination.password
    else
      roundrobin = tournament.roundrobin
      key = "roundrobin_#{roundrobin.id}"
      ret = roundrobin.password.blank? || cookies[key] == roundrobin.password
    end

    ret
  end

  def tournament_name(tournament_id)
    tournament = Tournament.find_by(id: tournament_id)
    return nil unless tournament

    tournament.name
  end

  def tournament_path(tournament_id)
    tournament = Tournament.find_by(id: tournament_id)
    return nil unless tournament

    if tournament.elimination?
      elimination = tournament.elimination
      ret = elimination_draw_path(elimination)
    else
      roundrobin = tournament.roundrobin
      ret = roundrobin_draw_path(roundrobin)
    end

    ret
  end

end
