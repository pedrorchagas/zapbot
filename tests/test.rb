require "sqlite3"

db = SQLite3::Database.new("meubanco.db")
db.execute("CREATE TABLE IF NOT EXISTS usuarios (id INTEGER PRIMARY KEY, nome TEXT)")
db.execute("INSERT INTO usuarios (nome) VALUES (?)", ["Pedro"])