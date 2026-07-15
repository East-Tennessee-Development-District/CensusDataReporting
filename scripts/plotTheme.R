theme_light <- thematic::thematic_theme(bg = "#ceffdf", fg = "#0d4e6a", accent = "#59CDFF", font = "Poppins")
theme_dark <- thematic::thematic_theme(bg = "#ceffdf", fg = "#0d4e6a", accent = "red", font = "Poppins")
theme_set(theme_classic() +
            theme(axis.text.x=
                    element_text(angle=45,
                                 hjust=1)
            ))
scale_colour_discrete <- scale_colour_viridis_d
options(ggplot2.continuous.colour="mako")
options(ggplot2.continuous.fill = "mako")
options(ggplot2.discrete.colour = "mako_d")
options(ggplot2.discrete.fill = "mako_d")
options(ggplot2.ordinal.colour = "mako")
options(ggplot2.ordinal.fill = "mako")
scale_fill_discrete <- function(...) {
  #scale_fill_manual(..., values = viridis_qualitative_pal7)
  viridis::scale_fill_viridis(discrete = TRUE, option="G")
} 




# based on: https://mickael.canouil.fr/posts/2023-05-30-quarto-light-dark/
# light_theme <- function() {
#   ggthemes::theme_solarized_2() %+% 
#     theme(
#       plot.background = element_rect(fill = "#FFF1E5"),
#       panel.border = element_blank(),
#       axis.line = element_line(colour = "#586e75",
#                                linetype = 1),
#       axis.ticks = element_line(colour = "#586e75"),
#       axis.text = element_text(colour = "#002b36"),
#       legend.background = element_rect(fill = "#FFF1E5"))
# } 
# 
# theme_set(light_theme())
# 
# lightsvglite <- function(file, width, height) {
#   on.exit(reset_theme_settings())
#   theme_set(light_theme())
#   ggsave(
#     filename = file,
#     width = width,
#     height = height,
#     dev = "svg",
#     bg = "transparent"
#   )
# }
# theme_dark <- function() {
#   ggthemes::theme_solarized_2(light = F) %+%
#     theme(
#       text = element_text(colour = "white"),
#       axis.text = element_text(colour = "white"),
#       axis.title = element_text(colour = "white"),
#       legend.text = element_text(colour = "white"),
#       legend.title = element_text(colour = "white"),
#       strip.text = element_text(colour = "white"),
#       rect = element_rect(colour = "#272b30", fill = "#272b30"),
#       plot.background = element_rect(fill = "#222222", colour = NA),
#       axis.line = element_line(colour = "white"),
#       axis.ticks = element_line(colour = "white"),
#       plot.title = element_text(colour = "white"),
#       plot.subtitle = element_text(colour = "white"),
#       plot.caption = element_text(colour = "white"),
#       legend.background = element_rect(fill = "#222222")
#     )
# }
# 
# darksvglite <- function(file, width, height) {
#   on.exit(reset_theme_settings())
#   theme_set(theme_dark())
#   ggsave(
#     filename = file,
#     width = width,
#     height = height,
#     dev = "svg",
#     bg = "transparent"
#   )
# }