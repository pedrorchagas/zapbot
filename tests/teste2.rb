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

puts "Qual é o seu nome?"
entrada = gets.chomp

nome_extraido = extrair_nome(entrada)
puts "Nome extraído: #{nome_extraido}"