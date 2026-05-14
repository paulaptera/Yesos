library(ggplot2)

# Media
mean_protection <- mean(
  results_df$protected_percent,
  na.rm = TRUE
)

# Boxplot
ggplot(
  results_df,
  aes(y = protected_percent)
) +
  
  geom_boxplot() +
  
  # Línea media
  geom_hline(
    yintercept = mean_protection,
    linetype = "dashed"
  ) +
  
  # Punto media
  annotate(
    "point",
    x = 1,
    y = mean_protection,
    size = 3
  ) +
  
  labs(
    y = "Protected area (%)",
    title = "Protection percentage across species"
  ) +
  
  theme_minimal()
