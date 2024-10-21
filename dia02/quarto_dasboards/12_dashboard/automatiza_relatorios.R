# Carregar os pacotes necessários
library(quarto)
library(tidyverse)
library(here)
library(fs)

# define as cidades para as quais queremos gerar relatórios
cidades <- c("Formiga", "Arcos", "Pimenta", "Piumhi")

# cria a pasta relatórios
dir_create(here::here("dia01/quarto/01_relatorio_parametrizado/relatorios"))

# cria um tibble com as informações de entrada e saída
reports <- tibble(
  input = here::here("dia01/quarto/01_relatorio_parametrizado/01_relatorio_parametrizado.qmd"),
  output_temp = here::here("dia01/quarto/01_relatorio_parametrizado/01_relatorio_parametrizado.html"),  # Arquivo gerado
  output_dest = here::here("dia01/quarto/01_relatorio_parametrizado/relatorios", 
                           str_glue("relatorio_vendas_{cidades}.html")),  # Arquivo de saída desejado
  execute_params = map(cidades, ~ list(cidade = .))
)

# usar pwalk para renderizar os relatórios e renomear o arquivo gerado
pwalk(reports, function(input, output_temp, output_dest, execute_params) {
  # Renderizar o relatório
  quarto_render(input = input, execute_params = execute_params)
  
  # Renomear o arquivo gerado para o nome da cidade correta
  file_move(output_temp, output_dest)
  
  message(paste("Relatório gerado e movido para:", output_dest))
})
