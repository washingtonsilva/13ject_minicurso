# Carrega os pacotes necessários
library(here)       # para usar caminhos relativos de arquivos
library(tidyverse)  # metapacote: tibble
library(fs)         # para gerenciamento de arquivos e pastas
library(quarto)     # parra renderizar arquivos .qmd via comandos

# Define as cidades para as quais queremos gerar relatórios
cidades <- c("Formiga", "Arcos", "Pimenta", "Piumhi")

# Cria a pasta de relatórios, caso não exista
dir_create(here::here("dia01/quarto/02_relatorio_parametrizado/relatorios"))

# Cria uma tibble com as informações de entrada e saída
reports <- tibble(
  input = here::here("dia01/quarto/02_relatorio_parametrizado/02_relatorio_parametrizado.qmd"),
  output_temp = here::here("dia01/quarto/02_relatorio_parametrizado/02_relatorio_parametrizado.html"),
  output_dest = here::here("dia01/quarto/02_relatorio_parametrizado/relatorios", 
                           str_glue("relatorio_vendas_{cidades}.html")),
  execute_params = map(cidades, ~ list(cidade = .))
)

# Usa a função pwalk para renderizar os relatórios e renomear o arquivo gerado
pwalk(reports, function(input, output_temp, output_dest, execute_params) {
  # Renderiza o relatório
  quarto_render(input = input, execute_params = execute_params)
  # Renomear o arquivo gerado para o nome da cidade correta
  file_move(output_temp, output_dest)
  message(paste("Relatório gerado e movido para:", output_dest))
})
