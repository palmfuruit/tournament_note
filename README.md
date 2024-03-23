# Database復元

参考  
 https://docs.render.com/postgresql-backups

手順  
.sqlバックアップファイルを用意。  
Linux環境(postgresqlインストール済の環境)でpsqlを実行する。

```psql ($external_database_url) -f ($backup_file)```  
↓   
ex) Staging環境へ本番データを流し込む。  
```psql postgres://tournament_note_staging_db_user:Uo20SlmFgr9TnzdauMm6t4LudMZ0bwHQ@dpg-cnv6g9ta73kc73c7d3q0-a.singapore-postgres.render.com/tournament_note_staging_db -f ~/Downloads/2024-03-22T04_14Z.sql```



