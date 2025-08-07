# Cincinnati Police Reported Crime Statistics

This project generates interactive maps and statistics from Cincinnati Police incident-level crime data.

## Features

- Cleans and processes raw reported crime data.
- Filters incidents by year, location, and crime category.
- Visualizes incidents on an interactive map using [leaflet](https://rstudio.github.io/leaflet/).
- Color-codes incidents by crime category.
- Provides popups with details (category, neighborhood, date, address).
- Generates individual maps for each major crime category.

## Crime Categories Mapped

- Homicide
- Rape
- Robbery
- Aggravated Assault
- Strangulation
- Burglary
- Auto Theft
- Theft from Auto
- Personal/Other Theft

## Requirements

- R (version 4.0+ recommended)
- R packages: `dplyr`, `lubridate`, `readxl`, `tidyr`, `sf`, `ggplot2`, `ggspatial`, `leaflet`, `RColorBrewer`, `htmlwidgets`

Install missing packages in R:

```r
install.packages(c(
    "dplyr", "lubridate", "readxl", "tidyr", "sf",
    "ggplot2", "ggspatial", "leaflet", "RColorBrewer", "htmlwidgets"
))
```

## Usage

1. Place your raw incident data as `data/Reported_Crime.csv`.
2. Run `crime_stats.R` in R.
3. The main interactive map will be saved as `output/map.html`.
4. Individual crime category maps are available in R as the `crime_maps` list.

## Output

- **Interactive Map:** `output/map.html` (view in your browser)
- **Individual Category Maps:** Access in R via `crime_maps[["Category"]]`

## Notes

- Only incidents with valid coordinates and within Cincinnati bounds are mapped.
- Date fields are auto-parsed for flexibility.
- The script uses muted color palettes for clarity.