# Carrega os pacotes necessários 
library(shiny)   # Pacote que cria aplicativos web interativos em R
library(ggplot2) # Pacote para criar o gráfico de linha
library(scales)  # Pacote para formatar os valores dos eixos no gráfico

# Define a interface do usuário (UI) do aplicativo
ui <- page_sidebar(
  # Título principal da aplicação
  title = "Calculadora de Prestações",
  
  # Barra lateral com entradas de dados do usuário
  sidebar = sidebar(
    # Campo para o usuário inserir o valor da compra
    numericInput("valor_compra", "Valor da compra (R$)", value = 10000, min = 0),
    # Campo para o usuário inserir a taxa de juros mensal
    numericInput("taxa_juros", "Taxa de juros mensal (%)", value = 2, min = 0, max = 100, step = 0.1),
    # Campo para o usuário inserir o número de prestações
    numericInput("num_prestacoes", "Número de prestações", value = 12, min = 1, max = 360),
    # Campo para o usuário inserir o valor da entrada (opcional)
    numericInput("valor_entrada", "Valor da entrada (R$)", value = 0, min = 0),
    # Botão para iniciar o cálculo
    actionButton("calcular", "Calcular", class = "btn-primary"),
    # Botão para resetar os valores e começar de novo
    actionButton("reset", "Resetar", class = "btn-secondary")
  ),
  
  # Layout em colunas para os resultados
  layout_columns(
    # Exibe os resultados dos cálculos em textos
    card(
      card_header("Resultados"),
      textOutput("valor_prestacao"),
      textOutput("valor_total"),
      textOutput("total_juros")
    ),
    # Gráfico que mostrará a evolução do saldo devedor
    card(
      card_header("Evolução do Saldo Devedor"),
      plotOutput("grafico_evolucao")
    )
  ),
  
  # Card de ajuda com instruções para o usuário entender como usar a calculadora
  card(
    card_header("Ajuda e Instruções"),
    "Esta calculadora permite simular o financiamento de uma compra. Preencha os campos:",
    tags$ul(
      tags$li("Valor da compra: O valor total do bem ou serviço."),
      tags$li("Taxa de juros mensal: A taxa de juros aplicada mensalmente."),
      tags$li("Número de prestações: Quantas parcelas mensais para pagar."),
      tags$li("Valor da entrada (opcional): Um pagamento inicial, se houver.")
    ),
    "Os cálculos são baseados no Sistema de Amortização Francês (Price). A fórmula usada é:",
    tags$pre("Prestação = [F * i * (1 + i)^n] / [(1 + i)^n - 1]"),
    "Onde F é o valor financiado, i é a taxa de juros mensal, e n é o número de prestações."
  )
)

# Função servidor onde a lógica do aplicativo é implementada
server <- function(input, output, session) {
  
  # Variável reativa para armazenar os resultados dos cálculos
  valores <- reactiveVal(list())
  
  # Evento disparado quando o usuário clica no botão "Calcular"
  observeEvent(input$calcular, {
    # Calcula o valor financiado subtraindo a entrada do valor total da compra
    valor_financiado <- input$valor_compra - input$valor_entrada
    # Converte a taxa de juros de porcentagem para decimal
    taxa <- input$taxa_juros / 100
    # Armazena o número de prestações
    n <- input$num_prestacoes
    
    # Calcula o valor da prestação usando a fórmula do sistema Price
    prestacao <- (valor_financiado * taxa * (1 + taxa)^n) / ((1 + taxa)^n - 1)
    # Calcula o valor total pago ao final do financiamento
    total_pago <- prestacao * n
    # Calcula o total de juros pagos
    total_juros <- total_pago - valor_financiado
    
    # Armazena os resultados na variável reativa 'valores'
    valores(list(
      prestacao = prestacao,
      total_pago = total_pago,
      total_juros = total_juros,
      valor_financiado = valor_financiado,
      taxa = taxa,
      n = n
    ))
    
    # Exibe o valor da prestação formatado com 2 casas decimais
    output$valor_prestacao <- renderText({
      paste("Valor da prestação: R$", format(round(prestacao, 2), big.mark = ".", decimal.mark = ","))
    })
    
    # Exibe o valor total pago formatado
    output$valor_total <- renderText({
      paste("Valor total pago: R$", format(round(total_pago, 2), big.mark = ".", decimal.mark = ","))
    })
    
    # Exibe o total de juros pagos formatado
    output$total_juros <- renderText({
      paste("Total de juros pagos: R$", format(round(total_juros, 2), big.mark = ".", decimal.mark = ","))
    })
    
    # Renderiza o gráfico da evolução do saldo devedor ao longo das prestações
    output$grafico_evolucao <- renderPlot({
      # Inicializa o saldo devedor
      saldo_devedor <- numeric(n)
      saldo_devedor[1] <- valor_financiado
      # Calcula o saldo devedor após cada prestação
      for (i in 2:n) {
        juros <- saldo_devedor[i-1] * taxa
        amortizacao <- prestacao - juros
        saldo_devedor[i] <- saldo_devedor[i-1] - amortizacao
      }
      
      # Cria um dataframe com os meses e o saldo devedor correspondente
      df <- data.frame(mes = 1:n, saldo = saldo_devedor)
      
      # Plota o gráfico com ggplot2
      ggplot(df, aes(x = mes, y = saldo)) +
        geom_line() +
        geom_point() +
        labs(title = "Evolução do Saldo Devedor",
             x = "Mês",
             y = "Saldo Devedor (R$)") +
        scale_y_continuous(labels = label_number(big.mark = ".", decimal.mark = ",")) +
        theme_minimal()
    })
  })
  
  # Evento disparado quando o usuário clica no botão "Resetar"
  observeEvent(input$reset, {
    # Reseta os campos de entrada para seus valores iniciais
    updateNumericInput(session, "valor_compra", value = 10000)
    updateNumericInput(session, "taxa_juros", value = 2)
    updateNumericInput(session, "num_prestacoes", value = 12)
    updateNumericInput(session, "valor_entrada", value = 0)
    
    # Limpa os valores armazenados e os resultados exibidos
    valores(list())
    output$valor_prestacao <- renderText("")
    output$valor_total <- renderText("")
    output$total_juros <- renderText("")
    output$grafico_evolucao <- renderPlot({})
  })
}

# Executa o aplicativo Shiny
shinyApp(ui, server)

