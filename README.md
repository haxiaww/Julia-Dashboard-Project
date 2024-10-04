# Sales Data Visualization in Julia

## Project Overview
This project demonstrates how to efficiently perform data cleaning, feature engineering, and interactive visualizations using Julia for a real-world sales dataset. The dataset used comprises sales data from various stores across Ecuador. The project showcases data processing, visualization, and exploration techniques, and it is built with `CSV.jl`, `DataFrames.jl`, `PlotlyJS.jl`, and `Dash.jl` for the frontend interactive dashboard.

The visualizations include trend analysis, sales comparisons by store and product, seasonal decomposition, and geographical insights. This project is part of a data analysis portfolio, demonstrating advanced data manipulation and visualization using Julia for business intelligence (BI) applications.

## Features
- **Data Preprocessing**: Merging multiple datasets (e.g., sales data, holidays), handling missing data, and feature engineering (e.g., creating time-based features such as day, week, month, and quarter).
- **Interactive Visualizations**:
  - Bar charts to compare sales across different stores and products.
  - Line charts to visualize sales trends over time.
  - Pie charts showing sales distribution across various categories.
  - Seasonality analysis and its effect on sales.
- **Dashboard**: Created using `Dash.jl`, allowing users to filter and explore data interactively (e.g., by state or product category).
- **Geographical Insights**: Visualizing sales across regions using location-based plots.

## Technologies Used
- **Language**: Julia
- **Libraries**:
  - `DataFrames.jl`: For handling tabular data and data manipulation.
  - `CSV.jl`: For reading and writing CSV files.
  - `PlotlyJS.jl`: For creating interactive visualizations.
  - `Dash.jl`: For building the interactive web dashboard.
  - `Dates.jl`: For feature engineering and manipulating time-based data.

## Project Structure
```bash
├── data/
│   ├── train.csv           # Sales data for training
│   ├── holidays.csv        # Holidays data
│   └── stores.csv          # Store information
├── src/
│   ├── data_preprocessing.jl    # Data cleaning and feature engineering
│   ├── visualizations.jl        # Code for generating visualizations
│   └── dashboard.jl             # Dash dashboard code
├── output/
│   ├── figures/           # Folder to store generated plots and graphs
├── README.md              # Project description and documentation
└── Project.toml           # Julia dependencies and environment file
