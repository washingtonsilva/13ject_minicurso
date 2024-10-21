# Carrega os pacotes necessários
library(tidyverse)  # Metapacote que inclui dplyr, ggplot2...
library(shiny)      # Pacote que cria aplicativos web interativos em R

# Importa os dados de um arquivo CSV usando o pacote readr e a função here
# O arquivo "dados_vendas.csv" deve estar na pasta especificada ("dados")
dados <- readr::read_csv(here::here("dados/dados_vendas.csv"))

# Define a interface do usuário (UI)
ui = fluidPage(
  # Título da aplicação exibido na parte superior
  titlePanel("Receita Diária nas Cidades"),
  
  # Layout com uma barra lateral e uma área principal
  sidebarLayout(
    # Painel lateral onde os usuários podem interagir com a aplicação
    sidebarPanel(
      # Botões de rádio para selecionar uma cidade
      radioButtons(
        "Cidade", "Selecione uma cidade",  # Label para os botões de rádio
        choices = c(
          "Formiga",  # Opção 1
          "Arcos",    # Opção 2
          "Pimenta",  # Opção 3
          "Piumhi"    # Opção 4
        )
      )
    ),
    
    # Painel principal onde o gráfico será exibido
    mainPanel( 
      plotOutput("plot")  # Área para exibir o gráfico gerado
    )
  )
)

# Define a lógica do servidor que processa as interações e gera o gráfico
server = function(input, output, session) {
  # A função renderPlot cria um gráfico com base nos dados filtrados
  output$plot = renderPlot({
    # Filtra os dados com base na cidade selecionada pelo usuário
    dados |>
      filter(Cidade %in% input$Cidade) |>
    # Cria um gráfico de linha usando ggplot2, com Data no eixo x e Receita no eixo y
      ggplot(aes(x = Data, y = Receita)) +
      geom_line() +  # Adiciona linhas conectando os pontos (geom_line)
      theme_minimal()  # Aplica um tema visual simples ao gráfico
  })
}

# Executa o aplicativo Shiny
shinyApp(ui = ui, server = server)
