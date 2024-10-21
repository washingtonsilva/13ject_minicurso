# Carregar os pacotes necessários
# - quarto: Para renderizar os documentos Quarto
# - tidyverse: Para manipulação de dados, como criar e manipular tibbles
# - here: Para definir caminhos de arquivos de forma segura e consistente
# - fs: Para operações de sistema de arquivos, como criar e mover pastas e arquivos
library(quarto)
library(tidyverse)
library(here)
library(fs)

# Definir as cidades para as quais queremos gerar relatórios
# Cada relatório será personalizado para uma dessas cidades
cidades <- c("Formiga", "Arcos", "Pimenta", "Piumhi")

# Criar a pasta de relatórios, caso ela ainda não exista
# Isso garante que os relatórios gerados sejam armazenados em um local adequado
dir_create(here::here("dia01/quarto/03_relatorio_parametrizado/relatorios"))

# Criar um tibble com as informações de entrada e saída
# - input: O caminho do arquivo .qmd que será usado como base
# - output_temp: O caminho temporário onde o arquivo será gerado inicialmente
# - output_dest: O caminho final do relatório, com o nome personalizado para cada cidade
# - execute_params: Parâmetros que serão passados para o relatório (neste caso, o nome da cidade)
reports <- tibble(
  input = here::here("dia01/quarto/03_relatorio_parametrizado/relatorio_vendas.qmd"), # Caminho do arquivo de template
  output_temp = here::here("dia01/quarto/03_relatorio_parametrizado/relatorio_vendas.pdf"),  # Relatório temporário
  output_dest = here::here("dia01/quarto/03_relatorio_parametrizado/relatorios", 
                           str_glue("relatorio_vendas_{cidades}.pdf")),  # Relatório final renomeado
  execute_params = map(cidades, ~ list(cidade = .))  # Parâmetro 'cidade' para cada relatório
)

# Usar pwalk para renderizar os relatórios e renomear o arquivo gerado
# - pwalk: Aplica a função a cada linha do tibble. Neste caso, gera um 
#          relatório para cada cidade
# - function: Define a função que será executada para cada linha
# - quarto_render: Renderiza o arquivo .qmd com os parâmetros fornecidos
# - file_move: Renomeia o arquivo temporário para o nome final (baseado na cidade)
pwalk(reports, function(input, output_temp, output_dest, execute_params) {
  # Renderizar o relatório para a cidade específica
  quarto_render(input = input, execute_params = execute_params)
  # Renomear o arquivo temporário para o nome da cidade correspondente
  file_move(output_temp, output_dest)
})

