library(dplyr)
library(ggplot2)

results <- read.csv("./data/performance.csv") %>% 
   mutate(fct_level = as.factor(level))


ggplot(results) +
   geom_point(aes(x = level, y = KK, shape = "Sparta to Slavia"), color = "blue") +
   geom_point(aes(x = level, y = SS, shape = "Karlín to Karlov"), color = "red") +
   scale_shape_manual(values = c("Karlín to Karlov" = 17,
                                 "Sparta to Slavia" = 15)) +
   labs(x = "Level of Grid Detail (cells per km²)",
        y = "Run Time\n[miliseconds]",
        shape = "Route:")

ggsave(paste0("./output/performance_v1.png"), type = "cairo",
       width = 2000, height = 1000, units = "px")

ggplot(results) +
   geom_point(aes(x = level, y = KK, shape = "Sparta to Slavia"), color = "blue") +
   geom_point(aes(x = level, y = SS, shape = "Karlín to Karlov"), color = "red") +
   scale_shape_manual(values = c("Karlín to Karlov" = 17,
                                 "Sparta to Slavia" = 15)) +
   scale_x_continuous(trans = "log2",
                      breaks = c(4^(0:5)),
                      labels = scales::math_format(2^.x, format = log2)) +
   labs(x = "Level of Grid Detail (cells per km²)",
        y = "Run Time\n[miliseconds]",
        shape = "Route:") +
   theme(axis.text.x = element_text(margin = margin(b = 5)))

ggsave(paste0("./output/performance_v2.png"), type = "cairo",
       width = 2000, height = 1000, units = "px")

model_src <- select(results, c(level, time = KK)) %>% 
   bind_rows(select(results, c(level, time = SS)))

model <- lm(time ~ level, data = model_src)

stargazer::stargazer(model)