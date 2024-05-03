module RoundrobinsHelper

  def div_tag__ranking_conditions(form:, priority:, items:)
    case priority
      when 1
        rankx_column = @roundrobin.rank1
        rankx_symbol = :rank1
      when 2
        rankx_column = @roundrobin.rank2
        rankx_symbol = :rank2
      when 3
        rankx_column = @roundrobin.rank3
        rankx_symbol = :rank3
      when 4
        rankx_column = @roundrobin.rank4
        rankx_symbol = :rank4
    end

    array = items.map { |item| [Roundrobin::RANK_CONDITION[item], item] }

    tag.div(class: ['col-6 col-md-3 mb-3'], data: { testid: "rank-condition#{priority}" }) {
      concat(tag.div {
        concat form.label(rankx_symbol, "順位条件#{priority}", class: 'form-control-label')
        concat form.select(rankx_symbol, options_for_select(array, rankx_column), {}, class: ['form-control'])
      })
    }
  end

end