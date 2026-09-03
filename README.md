# Seattle Traffic Safety Optimization

An optimization pipeline that identifies the Seattle intersections where safety improvements would have the greatest impact, based on historical collision severity — using linear programming, SQL, and interactive geospatial visualization.

## Overview

This project analyzes over a decade of Seattle Department of Transportation (SDOT) collision records to answer a practical question: **if a city could only invest in improving a limited number of intersections, which ones would prevent the most harm?**

Rather than ranking intersections by raw collision count alone, the project engineers a custom severity score (weighted by fatalities, serious injuries, and injuries) and uses **integer linear programming** to select the optimal subset of intersections that maximizes total severity impact under a configurable budget constraint. Results are stored in SQL databases and visualized on an interactive map.

## Features

- **Custom severity scoring** — collisions are weighted by outcome (fatality, serious injury, injury, property damage only) rather than treated as equally severe
- **Linear programming optimization** — uses [PuLP](https://coin-or.github.io/pulp/) to solve a binary knapsack-style problem: select the *N* intersections that maximize total severity score
- **Configurable scope** — the number of intersections considered (`num_of_intersections_considered`) can be adjusted, with automatic fallback to a sane default if an invalid value is provided
- **SQL integration** — collision data is loaded into SQLite databases for structured querying and downstream use
- **Interactive mapping** — selected intersections are plotted on a Folium map with popups showing collision counts and severity scores, after converting from Washington State Plane coordinates to standard latitude/longitude
- **Two ranking views** — compare intersections ranked by raw collision frequency vs. ranked by optimized severity impact

## Tech Stack

| Tool | Purpose |
|---|---|
| Python | Core language |
| pandas / numpy | Data cleaning, transformation, severity scoring |
| PuLP | Linear programming / optimization |
| SQLite (sqlite3) | Structured data storage |
| Folium | Interactive map visualization |
| pyproj | Coordinate system conversion (State Plane → WGS84) |

## Project Structure

\```
seattle-traffic-optimization/
├── data/
│   └── SDOT_Collisions_All_Years.csv.xz   # Compressed source dataset
├── Seattle_Collisions_Main.ipynb                          # Main analysis and optimization pipeline
├── most_severe_collisions_map.html         # Generated interactive map (output)
├── requirements.txt
├── .gitignore
└── README.md
\```

## Data Source

Collision records are sourced from the [Seattle Department of Transportation (SDOT) Collisions dataset](https://data.seattle.gov/), covering all recorded years. The raw CSV is compressed (`.xz`) in this repository to stay within GitHub's file size limits — pandas reads compressed files natively, no manual extraction needed.

## Setup

**1. Clone the repository**
\```bash
git clone https://github.com/owen-kimball/seattle-traffic-optimization.git
cd seattle-traffic-optimization
\```

**2. Install dependencies**
\```bash
pip install -r requirements.txt
\```

**3. Run the notebook**
Open `Seattle_Collisions_Main.ipynb` in Jupyter and run all cells. This will:
- Load and clean the collision data
- Compute severity scores
- Build and solve the optimization model
- Generate `collisions.db`, `severity_of_collisions.db`, and `most_severe_collisions_map.html` locally

> Database and map output files are excluded from version control (see `.gitignore`) since they're fully reproducible from the source data and code.

## How It Works

**1. Data cleaning & severity scoring**
Rows missing an intersection ID (`INTKEY`) are dropped, since collisions can't be attributed to a specific intersection without one. Each remaining collision is assigned a `severity_score`:
- Property damage only → `1`
- Otherwise → weighted sum of fatalities (×10), serious injuries (×5), and injuries (×2)

**2. Optimization model**
For each intersection, a binary decision variable is created (`1` = selected, `0` = not selected). The model maximizes the total severity score across selected intersections, subject to a constraint capping the number of intersections that can be chosen — mirroring a real-world limited budget or capacity constraint.

**3. Visualization**
Selected intersections' coordinates (originally in Washington State Plane North, feet) are converted to standard latitude/longitude and plotted on an interactive Folium map, with popups displaying each intersection's total collision count and severity score.

## Example Output

The pipeline produces two ranked tables:
- **Top intersections by raw collision count** — where collisions happen most often
- **Top intersections by optimized severity impact** — where the model recommends focusing safety investment

...along with an interactive map (`most_severe_collisions_map.html`) marking the optimally selected intersections.

## Possible Extensions

- Incorporate additional factors (weather, lighting, road conditions) into the severity model
- Add a cost dimension per intersection for a true budget-constrained optimization
- Compare optimized selections against actual city infrastructure investment records

## Author

Owen Kimball
