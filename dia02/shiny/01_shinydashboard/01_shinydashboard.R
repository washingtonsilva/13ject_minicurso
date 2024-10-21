# Carrega os pacotes
library(shiny)
library(shinydashboard)

# Define as Partes do Dashboard
ui <- dashboardPage(
  dashboardHeader(),  # cabeçalho
  dashboardSidebar(), # barra lateral
  dashboardBody()     # corpo
)

# Função personalizada executada no servidor (backend)
server <- function(input, output) { }

# Executa o App
shinyApp(ui, server)