
library(quarto)
library(tidyverse)
library(gapminder)

countries <-
  gapminder |>
  distinct(country) |>
  pull(country) |>
  as.character()

reports <-
  tibble(
    input = "dia01/quarto/04_relatorio_parametrizado/relatorio.qmd",
    output_file = str_glue("{countries}.html"),
    execute_params = map(countries, ~ list(country = .))
  )

pwalk(reports, quarto_render)