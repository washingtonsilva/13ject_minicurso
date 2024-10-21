
# Carregar os pacotes necessários
library(here)            # pacote para gerenciar caminhos de arquivos
library(tidyverse)       # metapacote que contém dplyr, readr,...
library(shiny)           # pacote principal para criar a aplicação Shiny
library(shinydashboard)  # pacote para criar o layout do dashboards
library(highcharter)     # pacote para gráficos interativos


## importa o arquivo dados_vendas.csv
caminho_csv <- here::here("dados/dados_vendas.csv")
dados_vendas <- readr::read_csv(caminho_csv)


# Interface do Usuário (UI)
ui <- dashboardPage(
  
  # Cabeçalho do dashboard
  dashboardHeader(title = "Dashboard de Vendas"),
  
  # Barra lateral para seleção de cidade
  dashboardSidebar(
    sidebarMenu(
      # Filtro para selecionar a cidade
      selectInput("cidade", "Selecione a Cidade:",
                  choices = unique(dados_vendas$Cidade),
                  selected = "Formiga"
      )
    )
  ),
  
  # Corpo principal do dashboard
  dashboardBody(
    fluidRow(
      # Gráfico interativo de barras com Highcharter
      box(
        title = "Receita Total por Produto para a Cidade Selecionada",
        status = "primary", solidHeader = TRUE,
        width = 12,
        highchartOutput("grafico_receita_interativo", height = 400) 
      )
    )
  )
)

# Servidor (lógica de backend)
server <- function(input, output) {
  
  # Filtra os dados de acordo com a cidade selecionada
  dados_filtrados <- reactive({
    dados_vendas %>%
      filter(Cidade == input$cidade)
  })
  
  # Gera o gráfico interativo de barras com a receita total por produto
  
  output$grafico_receita_interativo <- renderHighchart({
    dados_agrupados <- dados_filtrados() %>%
      group_by(Produto) %>%
      summarize(Receita_Total = sum(Receita))
    
    # Criação do gráfico de barras com highcharter
    
    highchart() %>%
      hc_chart(type = "column") %>%
      hc_title(text = paste("Receita Total por Produto para", input$cidade)) %>%
      hc_xAxis(categories = dados_agrupados$Produto) %>%
      hc_yAxis(title = list(text = "Receita Total (R$)")) %>%
      hc_add_series(name = "Receita Total",
                    data = dados_agrupados$Receita_Total,
                    colorByPoint = TRUE) %>%
      hc_tooltip(pointFormat = "Receita: R$ {point.y:,.2f}") %>%
      hc_plotOptions(column = list(
        dataLabels = list(enabled = TRUE, format = "R$ {point.y:,.2f}")
      ))
  })
}

# Executar o aplicativo Shiny
shinyApp(ui, server)
