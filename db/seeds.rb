# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# トーナメント表
30.times do |i|
  tournament = Tournament.create(tournament_type: :elimination)
  tournament.create_elimination(name: "トーナメント#{i+1}")
end


tournament = Tournament.create(tournament_type: :elimination)
tournament.create_elimination(name: "天下一武道会")
goku = tournament.teams.create(name: '悟空', color: 'orange', entryNo: 1)
kuririn = tournament.teams.create(name: 'クリリン', color: 'yellow', entryNo: 2)
tenshinhan = tournament.teams.create(name: '天津飯', color: 'blue', entryNo: 3)
chaozu = tournament.teams.create(name: '餃子', color: 'cyan', entryNo: 4)
tournament.games.create(round: 1, gameNo: 1, a_team: goku, b_team: kuririn, win_team: goku, lose_team: kuririn, a_result: 'WIN', b_result: 'LOSE')
tournament.games.create(round: 1, gameNo: 2, a_team: tenshinhan, b_team: chaozu, win_team: tenshinhan, lose_team: chaozu, a_result: 'WIN', b_result: 'LOSE')
tournament.games.create(round: 2, gameNo: 1, a_team: goku, b_team: tenshinhan, win_team: tenshinhan, lose_team: goku, a_result: 'LOSE', b_result: 'WIN')

# リーグ表
20.times do |i|
  tournament = Tournament.create(tournament_type: :roundrobin)
  tournament.create_roundrobin(name: "リーグ#{i+1}")
end

tournament = Tournament.create(tournament_type: :roundrobin)
tournament.create_roundrobin(name: "Group E", has_score: true, rank1: 'win_points', rank2: 'goal_diff', rank3: 'total_goals', rank4: 'head_to_head')
spain = tournament.teams.create(name: "スペイン", entryNo: 1)
germany = tournament.teams.create(name: "ドイツ", entryNo: 2)
costarica = tournament.teams.create(name: "コスタリカ", entryNo: 3)
japan = tournament.teams.create(name: "日本", entryNo: 4)
tournament.games.create(round: 1, a_team: germany, b_team: japan, win_team: japan, lose_team: germany, a_result: 'LOSE', b_result: 'WIN', a_score_num: 1, b_score_num: 2)
tournament.games.create(round: 1, a_team: spain, b_team: costarica, win_team: spain, lose_team: costarica, a_result: 'WIN', b_result: 'LOSE', a_score_num: 7, b_score_num: 0)
tournament.games.create(round: 1, a_team: spain, b_team: germany, win_team_id: 0, lose_team_id: 0, a_result: 'DRAW', b_result: 'DRAW', a_score_num: 1, b_score_num: 1)
tournament.games.create(round: 1, a_team: japan, b_team: costarica, win_team: costarica, lose_team: japan, a_result: 'LOSE', b_result: 'WIN', a_score_num: 0, b_score_num: 1)
tournament.games.create(round: 1, a_team: costarica, b_team: germany, win_team: germany, lose_team: costarica, a_result: 'LOSE', b_result: 'WIN', a_score_num: 2, b_score_num: 4)
tournament.games.create(round: 1, a_team: japan, b_team: spain, win_team: japan, lose_team: spain, a_result: 'WIN', b_result: 'LOSE', a_score_num: 2, b_score_num: 1)