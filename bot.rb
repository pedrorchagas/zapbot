require "redis"
require "json"
require "sqlite3"

# docker start redis-stack-server <- para iniciar o redis caso ele não tenha iniciado
@redis = Redis.new(host: "localhost", port: 6379)
@messages = JSON.parse(File.read("messages.json"), symbolize_names: true)


def extrair_nome(input)
    nome = input.match(/(?:meu nome é|me chamo|sou|eu sou)\s+([A-ZÀ-Ÿ][a-zà-ÿ]+(?:\s[A-ZÀ-Ÿ][a-zà-ÿ]+)?)|^([A-ZÀ-Ÿ][a-zà-ÿ]+(?:\s[A-ZÀ-Ÿ][a-zà-ÿ]+)?)$/i)
  
    if nome  # Se encontrou uma correspondência na regex
      if nome[1]  # Se o nome foi encontrado após uma frase ("Meu nome é ...")
        nome[1].capitalize!
        return nome[1]
      elsif nome[2]  # Se o nome foi digitado sozinho
        nome[1].capitalize!
        return nome[2]
      end
    end
  
    return "Nome não identificado"  # Se não encontrou nada válido
end


def get_response(user, message)

    # Primeiro estagio do fluxo de atendimento que é a apresentação e responsável por pegar o nome do usuário
    if user[:stage] == "begin"
        user[:stage] = "name"
        @redis.set(user[:id], user.to_json)

        return @messages[:begin][0]
    end 

    # Segunda parte do fluxo, salva a informação do nome e manda o menu para o usuario escolher
    if user[:name] == nil and user[:stage] == "name"
        user[:stage] = "menu"
        user[:name] = message
        @redis.set(user[:id], user.to_json)

        p user[:name]
        return @messages[:menu][0] % { name: user[:name] }
    end

    # Terceira, pega a opção do usuario e salva a escolha dele no cache
    p user[:name]
    options = ["1", "2", "3"]
    if user[:name] =! nil and user[:stage] == "menu" and options.include?(message)

        case message
        when "1" # marcar
            user[:stage] = "create-appointment-1"
            p user[:name]
            @redis.set(user[:id], user.to_json)
            return @messages[:"create-appointment-1"][0] % { name: user[:name] }
        #when "2" # desmarcar
        #when "3" # remarcar
        end
        
        #return "Poderia escrever apenas o numero das opções acima?"
    end
    
    # querto passo, pegar o dia para marcar o horario
    if user[:name] =! nil and user[:stage] == "create-appointment-1"
        
    end
    "Erro, poderia repetir?!"
end

# essa função ela é quem organiza a mensagem de input e coloca o usario no cache 
def input_message(user_id, message)

    user = @redis.get(user_id)

    if user.nil? 
        user = {name: nil, id: user_id, stage: "begin", option: nil}
        @redis.set(user_id, user.to_json)
    else
        user = JSON.parse(@redis.get(user_id), symbolize_names: true)
    end

    get_response(user, message)
end

#puts(input_message("105", "Olá"))
#puts(input_message("105", "Pedro"))

while true
    
    message = gets.chomp!

    if message == "sair"
        puts "saindo"
        break
    end

    puts input_message("local", message)

end


# limpa todo o cache para facilitar nos testes
@redis.flushall
