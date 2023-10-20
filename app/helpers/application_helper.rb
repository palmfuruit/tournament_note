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

  def default_meta_tags
    {
      site: 'Tournament Note',
      title: 'トーナメント表/リーグ表の作成・共有 Webアプリ',
      reverse: true,
      charset: 'utf-8',
      description: 'トーナメント表、リーグ表を無料で作成・共有するWebアプリです。スマホのブラウザから簡単に作成できます。スポーツやゲームの記録、進行管理に。',
      keywords: 'トーナメント表,リーグ表,対戦表,ドロー表,アプリ,ツール,Webサービス',
      separator: '|',
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: 'website',
        url: root_url,
        image: image_url('ogp.png'), # 配置するパスやファイル名によって変更すること
        local: 'ja-JP'
      },
      # Twitter用の設定を個別で設定する
      twitter: {
        card: 'summary_large_image', # Twitterで表示する場合は大きいカードにする
        image: image_url('ogp.png') # 配置するパスやファイル名によって変更すること
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

end
