# Five dataset candidates for the MATH4993 final project

Prepared on 26 October 2026. These are **five alternatives**; choose one for the main project. All five CSV files were exported from downloaded CRAN source packages, with original data and documentation retained under `raw/`. No observations were fabricated, imputed, or deleted.

## Recommendation

**Choose Galicia wind for the strongest balance of an accessible story, substantial data, and circular-linear modelling. Choose homing pigeons for a more compact project with less data preparation.** ICU arrivals are the simplest introduction, feldspar offers a distinctive axial-data lesson, and paleomagnetic poles are the advanced 3D option.

| Candidate | Observations | Geometry | Suggested question | Difficulty |
|---|---:|---|---|---|
| [1. Galicia wind](01_galicia_wind.csv) | 19,488; 19,206 complete speed-direction pairs | Cylindrical | Does wind speed depend on the direction it comes from? | Medium |
| [2. Homing pigeons](02_homing_pigeons.csv) | 108; three treatment groups | Circular | Do the treatment groups differ in orientation relative to home? | Low-medium |
| [3. ICU arrival times](03_icu_arrival_times.csv) | 254 | Circular time | Are arrivals uniform through the day, or concentrated at particular times? | Low |
| [4. Feldspar orientations](04_feldspar_orientations.csv) | 133 | Axial circular | Do crystal axes show preferred orientations? | Low-medium |
| [5. Paleomagnetic poles](05_paleomagnetic_poles.csv) | 50 | Axial spherical | Are the pole axes isotropic, concentrated, or arranged around a plane? | High |

Difficulty is my assessment of a sensible project scope, not a property assigned by the source. Model suggestions below are starting points, not fitted results.

## What the assignment requires

I checked both rendered pages of `Final_Project.pdf`. Page 1 specifies circular/cylindrical/directional data, an explanation of statistical model(s), and implementation in R, Python, or another language. It requires a 15-20 minute video and PowerPoint, with names, title, introduction, analysis/interpretation, references, and presenters' faces visible. Submit the dataset, code in TXT format, PowerPoint, and video link separately; do not zip them. The stated deadline is **30 November 2026 at 10:00 am**.

**Brief discrepancy:** page 2 repeatedly mentions a “Grey model,” which conflicts with page 1's topic. This shortlist follows page 1. Ask the instructor which rubric applies before committing the final presentation to a model. There is no need to delay exploring the datasets.

## 1. Galicia wind: best overall scope

**Data and source.** Winter hourly wind speed and direction from the Atlantic coast of Galicia, Spain, covering records from November 2003 to February 2012. The source is `NPCirc::speed.wind`; [official dataset documentation](https://search.r-project.org/CRAN/refmans/NPCirc/html/speed.wind.html).

**Why choose it.** Direction wraps around at 360 degrees while speed is an ordinary positive measurement. This gives a direct example of cylindrical data and a useful question: which directions are associated with stronger winds? The sample supports descriptive wind roses, model estimation, diagnostics, and a manageable comparison between models.

**Possible model.** A Gamma regression with a log link and periodic predictors: `log(E[speed | theta]) = beta0 + beta1*cos(theta) + beta2*sin(theta)`. Compare an intercept-only model and, if justified, a second harmonic. This is a model of speed conditional on circular direction, not a full joint cylindrical distribution. A circular-linear kernel regression is a possible extension. Interpret associations rather than causal effects.

**Main limitation.** Hourly observations may be serially dependent, and whole periods are absent. There are 226 missing speeds and 260 missing directions; 282 rows lack at least one of the pair. Keep those rows in the saved file, select complete pairs explicitly for a model, and consider seasonal effects and time-block validation/inference. Do not assume 19,206 independent observations. The source does not specify the timestamps' timezone, so no timezone was assigned.

**Fields.** `year`, `month`, `day`, `hour`; `speed_m_s`; original `direction_deg`; derived `direction_rad` in [0, 2*pi). The source example uses geographical plotting conventions. Check the original buoy convention before interpreting a physical compass direction. The raw package also contains its published `speed.wind2` subset; it is not a sixth candidate and is not used in the main CSV.

## 2. Homing pigeons: best manageable presentation

**Data and source.** Bearings of 108 displaced pigeons, aligned so home is 0/360 degrees, with three treatments. Source: `circular::pigeons`; [official dataset documentation](https://search.r-project.org/CRAN/refmans/circular/html/pigeons.html). Original study: Gagliardo et al. (2008), *Journal of Experimental Biology*, 211, 2046-2051.

**Why choose it.** The biological question is easy to explain, the sample is small enough to inspect, and group comparisons give more substance than fitting one distribution. It naturally demonstrates why 359 and 1 degrees are close and why an ordinary arithmetic mean can mislead.

**Possible model.** Fit group-specific von Mises distributions, explaining mean direction `mu` and concentration `kappa`. Compare fitted curves, resultant lengths, and alignment toward home. A circular distribution comparison such as Watson-Wheeler can complement the model; check ties and test assumptions. Do not use Watson-Williams automatically when groups have different concentration or poor von Mises fits.

**Main limitation.** The export pools two release locations and has no location field. It cannot support a site-adjusted analysis, and a fitted group difference alone does not establish a causal mechanism. A diffuse or multimodal group may need a different model.

**Fields.** `treatment`: `c` = control (41 birds), `on` = olfactory nerve section (27), `v1` = ophthalmic branch of trigeminal nerve section (40); `bearing_deg`; derived `bearing_rad`. All observations are complete. Home-relative zero is not geographic north.

## 3. ICU arrival times: simplest circular story

**Data and source.** The 24-hour arrival times of 254 intensive-care patients recorded over about 12 months. Source: `circular::fisherB1`; [official dataset documentation](https://search.r-project.org/CRAN/refmans/circular/html/fisherB1.html). Original source: Cox and Lewis (1966), *The Statistical Analysis of Series of Events*, pp. 254-255.

**Why choose it.** Midnight connects the end and start of a day, making the need for circular statistics immediately understandable. The dataset is complete and has one variable, so most presentation time can go into explaining the model and interpreting its fit.

**Possible model.** Map clock time to an angle, compare a uniform model with a von Mises model, and examine a circular histogram and fitted density. If the shape has several peaks, a two-component von Mises mixture is a possible extension. Use an omnibus circular uniformity test when multiple peaks are plausible; a Rayleigh test alone can miss them.

**Main limitation.** These are historical times of day, without dates, patient covariates, or a modern hospital context. The data cannot answer weekday/weekend questions or justify present-day staffing recommendations. Arrival-time rounding/ties should inform test calibration.

**Fields and conversion.** `source_hours_dot_minutes` preserves the original encoding: `23.15` means 23:15. `time_hhmm` is the readable time; `decimal_hour = hour + minute/60`; `angle_deg = 15*decimal_hour`; `angle_rad = 2*pi*decimal_hour/24`. The conversion was checked against the source's separate `fisherB1c` object. All 254 rows are complete.

## 4. Feldspar orientations: clearest axial-data example

**Data and source.** Long-axis orientations of 133 feldspar laths in basalt, from `circular::fisherB2`; [official dataset documentation](https://search.r-project.org/CRAN/refmans/circular/html/fisherB2.html). The package credits N. M. Smith's 1988 University of Sydney thesis and Fisher (1993), p. 240.

**Why choose it.** A crystal axis has no arrow: 10 and 190 degrees describe the same orientation. This creates a focused project with a substantive mathematical idea beyond standard circular means. The data require almost no cleaning.

**Possible model.** Double the angles modulo 360, then fit a von Mises model to the doubled angles. On the original axis scale this is an axial von Mises model, proportional to `exp(kappa*cos(2*(theta-mu)))`, with `mu` defined modulo 180 degrees. Compare with axial uniformity and inspect whether a single preferred axis fits adequately.

**Main limitation.** There is only one angular measurement per lath and no sample/location covariates. Do not infer a specific rock-forming mechanism from orientation alone, or assume nearby crystals are independent without checking the original sampling context.

**Fields.** `axis_deg` preserves the original values in [0, 180); `doubled_angle_deg` and `doubled_angle_rad` are explicitly derived analysis variables. All 133 rows are complete. Convert a doubled-angle mean back by halving it; report the result modulo 180 degrees.

## 5. Paleomagnetic poles: advanced 3D option

**Data and source.** Fifty paleomagnetic pole positions from New Caledonian laterites, in `boot::polar`; [official dataset documentation](https://search.r-project.org/CRAN/refmans/boot/html/polar.html). Source: Fisher, Lewis and Embleton (1987), *Statistical Analysis of Spherical Data*.

**Why choose it.** This takes the project beyond a circle into 3D. Latitude and longitude become unit vectors on a sphere, allowing a visual explanation of orientation, concentration, and axial symmetry. It is a good choice if your group wants more mathematical depth and is comfortable learning a new distribution.

**Possible model.** Fit an angular central Gaussian model to the unit vectors, and use the orientation matrix and its eigenvectors to interpret the pattern. The [`Directional::acg.mle` documentation](https://search.r-project.org/CRAN/refmans/Directional/html/vmf.mle.html) provides an R implementation. A Bingham distribution is another axial model, but would require additional implementation work.

**Main limitation.** The source represents axes by endpoints in the lower hemisphere: `x` and `-x` are equivalent. All-negative latitude is therefore a representation convention, not evidence of a southward directional preference. A standard directed von Mises-Fisher model on the recorded endpoints can mislead. The sample is small and this is the hardest option to explain within the time limit.

**Fields.** Original `latitude_deg` and `longitude_deg`, plus derived `x = cos(lat)*cos(lon)`, `y = cos(lat)*sin(lon)`, `z = sin(lat)`, with angles converted to radians before calculation. All 50 rows are complete; all vectors were checked to have unit length.

## Files, provenance, and reproducibility

- The five numbered CSVs are the main datasets. `source_row` is an added row index, not an original subject identifier.
- Missing values are saved as `NA`; no missing value is replaced with zero. CSV column names make units explicit.
- `validation_summary.csv` gives verified dimensions, missing cells, and complete rows for original variables. Added conversion columns are excluded from those counts.
- `raw/` contains unmodified source data, the original R help files (`.Rd`), package descriptions, and available license text.
- `sources.csv` records package versions, source-package download URLs, documentation URLs, and retrieval date. `checksums.sha256` records the downloaded raw files and exported CSVs.
- Run `Rscript scripts/prepare_candidate_data.R` from the repository root to recreate all five CSVs offline. Base R is sufficient.

Quick start in R:

```r
wind <- read.csv("data/candidates/01_galicia_wind.csv")
wind_complete <- subset(wind, !is.na(speed_m_s) & !is.na(direction_rad))
pigeons <- read.csv("data/candidates/02_homing_pigeons.csv")
icu <- read.csv("data/candidates/03_icu_arrival_times.csv")
feldspar <- read.csv("data/candidates/04_feldspar_orientations.csv")
poles <- read.csv("data/candidates/05_paleomagnetic_poles.csv")
```

Use the source citations in your eventual presentation. The supplied script prepares and validates data; it does not fit the proposed models or constitute the final project analysis.
