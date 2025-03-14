# Load necessary libraries
library(ggplot2)
library(dplyr)
library(lubridate)
library(readxl)
library(stringr)

# Step 1: Load the data from the Excel file
data <- read_excel("C:/Documents/GitHubRepos/Adidas-Sales-Dashboard/data/Adidas US Sales Datasets.xlsx")

# -----------------------------
# Basic Data Exploration
# -----------------------------

# View the first 5 rows
cat("\nFirst 5 Rows of the Data:\n")
head(data, 5)

# View the structure of the data
cat("\nStructure of the Data:\n")
str(data)

# Summary statistics
cat("\nSummary Statistics:\n")
summary(data)

# Check for missing values
cat("\nMissing Values Count:\n")
colSums(is.na(data))

# -----------------------------
# Step 2: Convert Invoice Date to Date format and create new columns for Year and Month
# -----------------------------
data <- data %>%
  mutate(
    Invoice_Date = as.Date(`Invoice Date`),
    Year = year(Invoice_Date),
    Month = month(Invoice_Date, label = TRUE, abbr = TRUE)
  )

# -----------------------------
# Step 3: Calculate total sales by month and year
# -----------------------------
monthly_sales <- data %>%
  group_by(Year, Month) %>%
  summarize(
    Total_Sales = sum(`Total Sales`, na.rm = TRUE),
    Avg_Price = mean(`Price per Unit`, na.rm = TRUE),
    Total_Units_Sold = sum(`Units Sold`, na.rm = TRUE),
    .groups = 'drop'
  )

# -----------------------------
# 1. Total Sales Over Time for Each Year
# -----------------------------
years <- unique(monthly_sales$Year)

for (year in years) {
  yearly_data <- filter(monthly_sales, Year == year)
  
  ggplot(yearly_data, aes(x = Month, y = Total_Sales, group = 1)) +
    geom_line(color = "blue", linewidth = 1) +
    geom_point(color = "red", size = 2) +
    labs(title = paste("Total Sales Over Time -", year),
         x = "Month", y = "Total Sales ($)") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

# -----------------------------
# 2. Total Sales by Product Category
# -----------------------------
product_sales <- data %>%
  group_by(Product) %>%
  summarize(Total_Sales = sum(`Total Sales`, na.rm = TRUE), .groups = 'drop')

ggplot(product_sales, aes(x = reorder(Product, -Total_Sales), y = Total_Sales)) +
  geom_bar(stat = "identity", fill = "lightblue") +
  labs(title = "Total Sales by Product Category",
       x = "Product", y = "Total Sales ($)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# -----------------------------
# 3. Operating Profit vs Total Sales (Scatter Plot)
# -----------------------------
ggplot(data, aes(x = `Total Sales`, y = `Operating Profit`)) +
  geom_point(color = "purple", alpha = 0.5) +
  labs(title = "Operating Profit vs Total Sales",
       x = "Total Sales ($)",
       y = "Operating Profit ($)") +
  theme_minimal()

# -----------------------------
# 4. Total Sales by Region
# -----------------------------
region_sales <- data %>%
  group_by(Region) %>%
  summarize(Total_Sales = sum(`Total Sales`, na.rm = TRUE), .groups = 'drop')

ggplot(region_sales, aes(x = reorder(Region, -Total_Sales), y = Total_Sales)) +
  geom_bar(stat = "identity", fill = "darkorange") +
  labs(title = "Total Sales by Region",
       x = "Region", y = "Total Sales ($)") +
  theme_minimal()

# -----------------------------
# 5. Total Sales by Sales Method
# -----------------------------
sales_method_sales <- data %>%
  group_by(`Sales Method`) %>%
  summarize(Total_Sales = sum(`Total Sales`, na.rm = TRUE), .groups = 'drop')

ggplot(sales_method_sales, aes(x = reorder(`Sales Method`, -Total_Sales), y = Total_Sales)) +
  geom_bar(stat = "identity", fill = "seagreen") +
  labs(title = "Total Sales by Sales Method",
       x = "Sales Method", y = "Total Sales ($)") +
  theme_minimal()

# -----------------------------
# 6. Cumulative Sales Growth Over Time
# -----------------------------
monthly_sales <- monthly_sales %>%
  arrange(Year, Month) %>%
  mutate(
    Date = as.Date(paste(Year, Month, "01", sep = "-"), format = "%Y-%b-%d"),
    Cumulative_Sales = cumsum(Total_Sales)
  )

# Plot cumulative sales growth over time
ggplot(monthly_sales, aes(x = Date, y = Cumulative_Sales, group = 1)) +
  geom_line(color = "green", linewidth = 1) +
  labs(title = "Cumulative Sales Growth Over Time",
       x = "Month-Year",
       y = "Cumulative Sales ($)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
# -----------------------------
# 7. Profitability by Product Category
# -----------------------------
product_profit <- data %>%
  group_by(Product) %>%
  summarize(Total_Profit = sum(`Operating Profit`, na.rm = TRUE), .groups = 'drop')

ggplot(product_profit, aes(x = reorder(Product, -Total_Profit), y = Total_Profit)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(title = "Total Profit by Product Category",
       x = "Product", y = "Operating Profit ($)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# -----------------------------
# 8. Sales by Region and Product Category
# -----------------------------
region_product_sales <- data %>%
  group_by(Region, Product) %>%
  summarize(Total_Sales = sum(`Total Sales`, na.rm = TRUE), .groups = 'drop')

ggplot(region_product_sales, aes(x = Region, y = Total_Sales, fill = Product)) +
  geom_bar(stat = "identity") +
  labs(title = "Sales by Region and Product Category",
       x = "Region", y = "Total Sales ($)") +
  theme_minimal()

# -----------------------------
# Done!
# -----------------------------
cat("\nll plots have been generated.\n")
