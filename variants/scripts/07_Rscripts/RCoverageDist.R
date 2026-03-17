#----------------------------------
# WES Coverage Summary Statistics & Histogram
#----------------------------------
library(tidyverse)

#----------------------------------
# 1. Load coverage data
#----------------------------------
cov <- read.table("results/04_alignQC/coverage/coverage_1kb.bed.gz",
                  header=FALSE, stringsAsFactors=FALSE)
colnames(cov) <- c("chromosome", "start", "end", "mean", "median", "count")

# Convert numeric and remove NAs
cov <- cov %>%
  mutate(
    mean = as.numeric(mean),
    median = as.numeric(median)
  ) %>%
  filter(!is.na(mean) & !is.na(median))

#----------------------------------
# 2. Filter standard chromosomes
#----------------------------------
cov <- cov %>% filter(chromosome %in% c(as.character(1:22), "X", "Y"))

#----------------------------------
# 3. Filter for captured regions
#----------------------------------
# Remove near-zero windows (off-target)
cov_filtered <- cov %>% filter(mean > 5)  # Adjust >5 depending on your data

# Optional: compute basic stats
median_cov <- median(cov_filtered$mean)
mean_cov <- mean(cov_filtered$mean)
cat("Median coverage in captured windows:", median_cov, "\n")
cat("Mean coverage in captured windows:", mean_cov, "\n")

#----------------------------------
# 4. Set thresholds relative to captured regions
#----------------------------------
# Example: ~half and double the median
low_threshold <- median_cov * 0.5
high_threshold <- median_cov * 2

cov_filtered <- cov_filtered %>%
  mutate(exclude = mean < low_threshold | mean > high_threshold)

#----------------------------------
# 5. Summary statistics per chromosome
#----------------------------------
coverage_summary <- cov_filtered %>%
  group_by(chromosome) %>%
  summarise(
    n_windows = n(),
    median_cov = median(mean),
    mean_cov = mean(mean),
    n_below = sum(mean < low_threshold),
    n_above = sum(mean > high_threshold)
  )

print(coverage_summary)

#----------------------------------
# 5. Histogram per chromosome (density-scaled)
#----------------------------------
ggplot(cov_filtered, aes(x=mean)) +
  geom_histogram(aes(y=..density..), binwidth=2, fill="steelblue", color="black") +
  facet_wrap(~chromosome, scales="free_y") +
  geom_vline(xintercept=c(low_threshold, high_threshold),
             linetype="dashed", color="red", size=1) +
  xlim(0, median_cov*3) +
  labs(title="WES Coverage per Chromosome (Density of Captured Windows)",
       x="Mean coverage per 1kb window", y="Density") +
  theme_bw() +
  theme(legend.position="none")

#----------------------------------
# 6. Overall histogram for all captured windows
#----------------------------------
ggplot(cov_filtered, aes(x=mean)) +
  geom_histogram(aes(y=..density..), binwidth=2, fill="forestgreen", color="black") +
  geom_vline(xintercept=c(low_threshold, high_threshold),
             linetype="dashed", color="red", size=1) +
  xlim(0, median_cov*3) +
  labs(title="Overall WES Coverage Distribution (Captured Windows Only)",
       x="Mean coverage per 1kb window", y="Density") +
  theme_bw()

#----------------------------------
# 7. Save plots
#----------------------------------
# 7a. Save per-chromosome histogram
per_chr_plot <- ggplot(cov_filtered, aes(x=mean)) +
  geom_histogram(aes(y=..density..), binwidth=2, fill="steelblue", color="black") +
  facet_wrap(~chromosome, scales="free_y") +
  geom_vline(xintercept=c(low_threshold, high_threshold),
             linetype="dashed", color="red", size=1) +
  xlim(0, median_cov*3) +
  labs(title="WES Coverage per Chromosome (Density of Captured Windows)",
       x="Mean coverage per 1kb window", y="Density") +
  theme_bw() +
  theme(legend.position="none")

ggsave("wes_coverage_per_chromosome.png", plot=per_chr_plot, width=12, height=8, dpi=300)

# 7b. Save overall histogram
overall_plot <- ggplot(cov_filtered, aes(x=mean)) +
  geom_histogram(aes(y=..density..), binwidth=2, fill="forestgreen", color="black") +
  geom_vline(xintercept=c(low_threshold, high_threshold),
             linetype="dashed", color="red", size=1) +
  xlim(0, median_cov*3) +
  labs(title="Overall WES Coverage Distribution (Captured Windows Only)",
       x="Mean coverage per 1kb window", y="Density") +
  theme_bw()

ggsave("wes_coverage_overall.png", plot=overall_plot, width=8, height=6, dpi=300)
