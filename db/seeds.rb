# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# トーナメント表
tournament = Tournament.create(tournament_type: :elimination)
tournament.create_elimination(name: "2チーム")
tournament.teams.create(name: 'Team1', color: 'red', entryNo: 1)
tournament.teams.create(name: 'Team2', color: 'blue', entryNo: 2)

tournament = Tournament.create(tournament_type: :elimination)
tournament.create_elimination(name: "4チーム")
(1..4).each do |i|
  tournament.teams.create(name: "Team#{i}", entryNo: i)
end

tournament = Tournament.create(tournament_type: :elimination)
tournament.create_elimination(name: "6チーム")
(1..6).each do |i|
  tournament.teams.create(name: "Team#{i}", entryNo: i)
end

tournament = Tournament.create(tournament_type: :elimination)
tournament.create_elimination(name: "8チーム")
(1..8).each do |i|
  tournament.teams.create(name: "Team#{i}", entryNo: i)
end

tournament = Tournament.create(tournament_type: :elimination)
tournament.create_elimination(name: "ワールドカップ16")
(1..16).each do |i|
  tournament.teams.create(name: "Team#{i}", entryNo: i)
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
tournament = Tournament.create(tournament_type: :roundrobin)
tournament.create_roundrobin(name: "2チーム")
tournament.teams.create(name: "Team1", color: 'red', entryNo: 1)
tournament.teams.create(name: "Team2", color: 'blue', entryNo: 2)

tournament = Tournament.create(tournament_type: :roundrobin)
tournament.create_roundrobin(name: "4チーム")
(1..4).each do |i|
  tournament.teams.create(name: "Team#{i}", entryNo: i)
end

tournament = Tournament.create(tournament_type: :roundrobin)
tournament.create_roundrobin(name: "8チーム")
(1..8).each do |i|
  tournament.teams.create(name: "Team#{i}", entryNo: i)
end

tournament = Tournament.create(tournament_type: :roundrobin)
tournament.create_roundrobin(name: "16チーム")
(1..16).each do |i|
  tournament.teams.create(name: "Team#{i}", entryNo: i)
end