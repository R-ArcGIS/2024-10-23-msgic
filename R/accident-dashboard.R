library(sf)
library(bslib)
library(dplyr)
library(arcgis)
library(plotly)
library(bsicons)
library(ggplot2)
library(leaflet)

theme_set(theme_minimal())
# open the feature server
crash_server <- arc_open("https://services.arcgis.com/UnTXoPXBYERF0OH6/arcgis/rest/services/Vehicle_Pedestrian_Incidents/FeatureServer")

# fetch individual layers
incidents <- get_layer(crash_server, 1)
hotspots <- get_layer(crash_server, 2)

# bring them into memory as sf objects
inci_sf <- arc_select(incidents)
hs_sf <- arc_select(hotspots)

# count the number of incidents by year
annual_counts <- inci_sf |>
  st_drop_geometry() |>
  mutate(year = lubridate::year(Incident_Date)) |>
  group_by(year) |>
  count() |>
  ungroup()

# make annual incidents plot
gg_annual <- ggplot(annual_counts, aes(year, n)) +
  geom_line() +
  geom_point(size = 3) +
  labs(
    x = "Year",
    y = "Incidents"
  )

# count incidents by speed
speed_counts <- inci_sf |>
  st_drop_geometry() |>
  count(Posted_Speed) |>
  filter(!is.na(Posted_Speed))

gg_speed <- ggplot(speed_counts, aes(Posted_Speed, n)) +
  geom_col() +
  labs(
    x = "Posted Speed Limit (miles per hour)",
    y = "Incidents"
  )

plot_tab <- navset_card_tab(
  title = "Plots",
  nav_panel(
    "By year",
    card_title("Vehicle-Pedestrian Incidents by Year"),
    ggplotly(gg_annual)
  ),
  nav_panel(
    "By speed",
    card_title("Vehicle Pedestrian Incidents by Posted Speed Limit"),
    ggplotly(gg_speed)
  )
)

n_incidents <- count(inci_sf) |>
  pull(n)

n_medical_transit <- inci_sf |>
  count(Involved_Medical_Transport) |>
  filter(Involved_Medical_Transport == "Yes") |>
  pull(n)

n_fatalities <- inci_sf |>
  count(Involved_Fatal_Injury) |>
  filter(Involved_Fatal_Injury == "Yes") |>
  pull(n)

n_alc_drug <- inci_sf |>
  filter(Drug_Involved == "Yes" | Alcohol_Involved == "Yes") |>
  count() |>
  pull(n)

inci_card <- value_box(
  "Number of Incidents",
  n_incidents,
  showcase = bs_icon("person")
)

fatalities_card <- value_box(
  "Total Fatalities",
  n_fatalities,
  showcase = bs_icon("heartbreak")
)

medical_card <- value_box(
  "Involved Medical Transport",
  n_medical_transit,
  showcase = bs_icon("heart-pulse")
)

drugs_card <- value_box(
  "Involved Drugs or Alcohol",
  n_alc_drug,
  showcase = bs_icon("capsule")
)

stats <- layout_columns(
  inci_card,
  fatalities_card,
  medical_card,
  drugs_card,
  col_widths = 6
)


rhs_col <- layout_columns(
  stats,
  plot_tab,
  col_widths = 12
)

hexes <- hs_sf |>
  transmute(
    classification = case_when(
      Gi_Bin == 0 ~ "Not Significant",
      Gi_Bin == 1 ~ "Hot Spot with 90% Confidence",
      Gi_Bin == 2 ~ "Hot Spot with 95% Confidence",
      Gi_Bin == 3 ~ "Hot Spot with 99% Confidence"
    )
  ) |>
  st_transform(4326)

# create labels vector to pass to leaflet
gi_labels <- c(
  "Not Significant",
  "Hot Spot with 90% Confidence",
  "Hot Spot with 95% Confidence",
  "Hot Spot with 99% Confidence"
)

pal <- colorFactor(
  palette = c("#c6c6c3", "#c8976e", "#be6448", "#af3129"),
  levels = gi_labels
)

map <- leaflet() |>
  addProviderTiles("Esri.WorldGrayCanvas") |>
  addPolygons(
    data = hexes,
    fillColor = ~pal(classification),
    color = "#c6c6c3",
    weight = 1,
    fillOpacity = 0.8
  ) |>
  addLegend(
    pal = pal,
    values = gi_labels,
    opacity = 1,
    title = "Hot Spot Classification"
  ) |>
  setView(-85.3, 35.04, 12.5)

map_card <- card(
  card_header("Vehicle-Pedestrian Incidents for Chattanooga, TN (2018-2023)"),
  map
)

dash_content <- layout_columns(
  map_card,
  rhs_col,
  col_widths = c(8, 4)
)

ui <- page_fillable(
  dash_content
)

# print ui to open the dashboard
ui


# save to files
# htmltools::save_html(ui, "dash/index.html")