# Cincinnati Police Reported Crime Statistics

This project generates interactive maps and statistics from Cincinnati Police incident-level crime data.

## Features

- Cleans and processes raw reported crime data from CSV.
- Automatically parses and standardizes date fields.
- Filters incidents by current year, valid coordinates, and selected crime categories.
- Excludes outliers by bounding incidents to the Cincinnati area.
- Visualizes incidents on an interactive map using [leaflet](https://rstudio.github.io/leaflet/), with muted color palettes for clarity.
- Color-codes incidents by crime category and provides popups with details (category, neighborhood, date, address).
- Generates individual interactive maps for each major crime category, accessible in R via the `crime_maps` list.
- Creates a heatmap visualization with interactive controls to switch between crime types.
- Saves main map and heatmap as standalone HTML files for easy sharing and viewing.

## Crime Categories Mapped

- Agg Assault
- Auto Theft
- Burglary/BE
- Homicide
- Part 2
- Personal/Other Theft
- Rape
- Robbery
- Strangulation
- Theft from Auto

## Requirements

- R (version 4.0 or higher recommended)
- R packages: `dplyr`, `lubridate`, `readxl`, `tidyr`, `sf`, `ggplot2`, `ggspatial`, `leaflet`, `leaflet.extras`, `RColorBrewer`, `htmlwidgets`

Install missing packages in R:

```r
install.packages(c(
    "dplyr", "lubridate", "readxl", "tidyr", "sf",
    "ggplot2", "ggspatial", "leaflet", "leaflet.extras",
    "RColorBrewer", "htmlwidgets"
))
```

## Usage

1. Place your raw incident data as `data/Reported_Crime.csv`.
2. Run `crime_stats.R` in R.
3. The main interactive map will be saved as `output/map.html`.
4. Individual crime category maps are available in R as the `crime_maps` list.

## Output

- **Interactive Map:** Saved as `output/map.html` (open in your browser for all incidents, color-coded by crime category).
- **Heatmap by Crime Type:** Saved as `output/heatmap_by_type.html` (interactive heatmap with controls to toggle between crime types).
- **Individual Category Maps:** Available in R as the `crime_maps` list, e.g., `crime_maps[["Robbery"]]` for a specific category.

## Notes

- Only incidents with valid coordinates and within Cincinnati bounds are mapped.
- Cincinnati skews coordinates for privacy purposes. [See their data notes here.](https://data.cincinnati-oh.gov/safety/Reported-Crime-STARS-Category-Offenses-on-or-after/7aqy-xrv9/about_data)
- Date fields are auto-parsed for flexibility.
- The script uses muted color palettes for clarity.

## View the Interactive Map

[Open the map on GitHub Pages](https://davidferrara23.github.io/enquirer-cpd-crime/output/map.html)