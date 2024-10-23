# Introduction to the R-ArcGIS Bridge

This repository contains the contents from [MSGIC workshop](https://msgic.glueup.com/event/spatial-data-science-in-arcgis-using-r-and-python-121505/) hosted on October 23rd, 2024. 

## Getting started

The majority of the workshop focuses on the use of the `{arcgis}` metapackage. First, you must install the R packages.

```r
install.packages(
  "arcgis",
  repos = c("https://r-arcgis.r-universe.dev", "https://cloud.r-project.org")
)
```

For more information, see our [installation instructions here](https://developers.arcgis.com/r-bridge/installation/).

Additional packages that will be used in the workshop: 

```r
install.packages(c("shiny", "bslib", "leaflet", "bsicons", "dplyr", "ggplot2", "plotly"))
```

## Downloading this repository

If you are familiar with Git and GitHub, please clone or fork the repository. 

Otherwise, download the folder using [this link](https://github.com/R-ArcGIS/2024-10-23-msgic/archive/refs/heads/main.zip).

- Unzip the `main.zip` folder in a location you can find again.
    - Give the folder a meaningful name e.g. `2024-10-23-msgic`
- Open RStudio
- Create a new project from **Existing Directory**
- Select the folder you unzipped

You now how an RStudio project for this workshop. 

## Configuring your credentials

This workshop assumes you have an **ArcGIS Online account** with the ability to **publish** content. 

You can get a [21 day trial here](https://www.esri.com/en-us/arcgis/products/arcgis-online/trial).

These steps below are described in detail on the documentation site [Authentication Overview](https://developers.arcgis.com/r-bridge/authentication/), [Storing Credentials](https://developers.arcgis.com/r-bridge/authentication/storing-credentials/), and [Authenticating with R](https://developers.arcgis.com/r-bridge/authentication/connecting-to-a-portal/). 

- Open the `.Renviron` file
- Replace `yourusername` with the username you use to login to ArcGIS Online
- Replace `yourpassword` with the password you use to sign into ArcGIS Online
- Optionally, if you use ArcGIS Enterprise, uncomment `ARCGIS_HOST` and provide the url of your portal. 
- Save the file
- Restart R



