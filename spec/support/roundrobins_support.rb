def have_mark(win_or_lose)
  case win_or_lose
    when 'win'
      have_selector 'i.bi.bi-circle'
    when 'draw'
      have_selector 'i.bi.bi-triangle'
    when 'lose'
      have_selector 'i.bi.bi-circle-fill'
    when ''
      have_selector 'i.bi'
  end
end
