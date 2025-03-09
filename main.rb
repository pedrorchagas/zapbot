require "sinatra"

get '/' do
    @name = "Pedro"
    @appointments = ["pedro martins", "amanda rodrigues", "lucas abel", "athos farias", "sarah gomes"]
    erb :teste
end