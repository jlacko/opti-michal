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
   geom_point(aes(x = fct_level, y = KK, shape = "Sparta to Slavia"), color = "blue") +
   geom_point(aes(x = fct_level, y = SS, shape = "Karlín to Karlov"), color = "red") +
   scale_shape_manual(values = c("Karlín to Karlov" = 17,
                                 "Sparta to Slavia" = 15)) +
   labs(x = "Level of Grid Detail (cells per km²)",
        y = "Run Time\n[miliseconds]",
        shape = "Route:")

ggsave(paste0("./output/performance_v2.png"), type = "cairo",
       width = 2000, height = 1000, units = "px")