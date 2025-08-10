# Cincinnati Police Reported Crime
# Generate crime statistics from incident-level data

# Load required libraries
library(dplyr)
library(lubridate)
library(readxl)
library(tidyr)
library(sf)
library(ggplot2)
library(dplyr)
library(ggspatial)
library(htmlwidgets)
library(leaflet)
library(leaflet.extras)
library(RColorBrewer)

incidents <- read.csv("data/Reported_Crime.csv", na.strings = c("", "NA"))

## CLEAN UP DATA

# Convert dates to proper format - auto-detect format
incidents$DateReported <- parse_date_time(incidents$DateReported, orders = c("mdy HMS p", "Y b d HMS p"))
incidents$DateFrom <- parse_date_time(incidents$DateFrom, orders = c("mdy HMS p", "Y b d HMS p"))
incidents$DateTo <- parse_date_time(incidents$DateTo, orders = c("mdy HMS p", "Y b d HMS p"))

# Using LATITUDE_X and LONGITUDE_X, create a neighborhood level map of incidents this year to date, color coded by category

# Define the full set of crime categories to use in maps and controls
crime_types <- c(
    "Agg Assault", "Auto Theft", "Burglary/BE", "Homicide", "Part 2",
    "Personal/Other Theft", "Rape", "Robbery", "Strangulation", "Theft from Auto"
)

# Filter incidents for this year and with valid coordinates
incidents_map <- incidents %>%
        filter(year(DateFrom) == year(today()),
                     !is.na(LATITUDE_X), !is.na(LONGITUDE_X),
                     STARS_Category %in% crime_types)

# Ensure coordinates are numeric and filter out obvious outliers
incidents_map$LONGITUDE_X <- as.numeric(incidents_map$LONGITUDE_X)
incidents_map$LATITUDE_X <- as.numeric(incidents_map$LATITUDE_X)

# Filter to reasonable Cincinnati area bounds (rough bounding box for Hamilton County)
incidents_map <- incidents_map %>%
    filter(LATITUDE_X >= 39.0 & LATITUDE_X <= 39.3,
           LONGITUDE_X >= -84.8 & LONGITUDE_X <= -84.2)

# Convert to sf object
incidents_sf <- st_as_sf(incidents_map, coords = c("LONGITUDE_X", "LATITUDE_X"), crs = 4326, remove = FALSE)

# Create color palette for all crime types
if(length(crime_types) <= 9) {
    crime_colors <- brewer.pal(length(crime_types), "Set2")  # Muted, pastel colors
} else {
    # For more than 9 categories, combine palettes
    crime_colors <- c(brewer.pal(8, "Set2"), brewer.pal(min(length(crime_types) - 8, 8), "Dark2"))
}
names(crime_colors) <- crime_types

# Create a color function for leaflet
color_pal <- colorFactor(palette = crime_colors, domain = crime_types)

# Create interactive map using leaflet (much better than plotly for maps)
interactive_map <- leaflet(incidents_sf) %>%
    addProviderTiles(providers$CartoDB.Positron) %>%  # Clean base map
    addCircleMarkers(
        lng = ~LONGITUDE_X,
        lat = ~LATITUDE_X,
        color = ~color_pal(STARS_Category),
        fillColor = ~color_pal(STARS_Category),
        radius = 4,
        stroke = TRUE,
        weight = 1,
        opacity = 0.9,
        fillOpacity = 0.7,
        popup = ~paste(
            "<b>", STARS_Category, "</b><br>",
            "Neighborhood:", SNA_Neighborhood, "<br>",
            "Date:", format(DateFrom, "%m/%d/%Y"), "<br>",
            "Address:", ADDRESS_X
        ),
        group = ~STARS_Category
    ) %>%
    addLayersControl(
        overlayGroups = crime_types,
        options = layersControlOptions(collapsed = FALSE)
    ) %>%
    addLegend(
        pal = color_pal,
        values = crime_types,
        title = "Crime Category",
        position = "bottomright",
        opacity = 0.8
    )

# Save the map
saveWidget(interactive_map, "output/map.html", selfcontained = TRUE)

# Display the interactive map
interactive_map

# Create individual maps for each crime category
crime_maps <- setNames(
    lapply(crime_types, function(cat) {
        cat_data <- incidents_sf[incidents_sf$STARS_Category == cat, ]
        cat_color <- crime_colors[cat]
        
        leaflet(cat_data) %>%
            addProviderTiles(providers$CartoDB.Positron) %>%
            addCircleMarkers(
                lng = ~LONGITUDE_X,
                lat = ~LATITUDE_X,
                color = cat_color,
                fillColor = cat_color,
                radius = 5,
                stroke = TRUE,
                weight = 1,
                opacity = 0.8,
                fillOpacity = 0.7,
                popup = ~paste(
                    "<b>", STARS_Category, "</b><br>",
                    "Neighborhood:", SNA_Neighborhood, "<br>",
                    "Date:", format(DateFrom, "%m/%d/%Y"), "<br>",
                    "Address:", ADDRESS_X
                )
            ) %>%
            addLegend(
                position = "bottomright",
                colors = cat_color,
                labels = cat,
                title = paste(cat, "Incidents"),
                opacity = 0.8
            )
    }),
    crime_types
)

# Generate a heatmap with interactive buttons to switch between crime types
# Create a base leaflet map
heatmap_map <- leaflet() %>%
    addProviderTiles(providers$CartoDB.Positron)

# Add each heatmap layer to the map, only if data exists for that category
for (cat in crime_types) {
    cat_data <- incidents_sf[incidents_sf$STARS_Category == cat, ]
    if (nrow(cat_data) > 0) {
        heatmap_map <- heatmap_map %>%
            addHeatmap(
                data = cat_data,
                lng = ~LONGITUDE_X,
                lat = ~LATITUDE_X,
                blur = 20,
                max = 0.05,
                radius = 15,
                group = cat
            )
    }
}

# Add layer controls to switch between crime types
heatmap_map <- heatmap_map %>%
    addLayersControl(
        overlayGroups = crime_types,
        options = layersControlOptions(collapsed = FALSE)
    )

# Save the heatmap map as a separate HTML file
saveWidget(heatmap_map, "output/heatmap_by_type.html", selfcontained = TRUE)

# Create separate heatmap for violent crimes
violent_crimes <- c("Homicide", "Robbery", "Strangulation", "Rape", "Agg Assault")

# Violent crime heatmap
violent_data <- incidents_sf[incidents_sf$STARS_Category %in% violent_crimes, ]
violent_heatmap <- leaflet() %>%
    addProviderTiles(providers$CartoDB.Positron) %>%
    addHeatmap(
        data = violent_data,
        lng = ~LONGITUDE_X,
        lat = ~LATITUDE_X,
        blur = 20,
        max = 0.05,
        radius = 15
    )
saveWidget(violent_heatmap, "output/heatmap_violent.html", selfcontained = TRUE)