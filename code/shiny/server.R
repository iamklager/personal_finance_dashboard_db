#### Server
# The server...


server <- function(input, output, session) {
  output$out_DTIncExp <- DT::renderDT({ data.frame(Foo = rnorm(5), Bar = paste0("Entry ", 1:5)) })
}