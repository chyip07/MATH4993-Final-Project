# Run from the project root: Rscript scripts/prepare_candidate_data.R
# Rebuild the five CSVs from the downloaded, unmodified source data.
# Only base R is required; no package installation and no network access.

options(stringsAsFactors = FALSE)
out <- "data/candidates"
raw <- file.path(out, "raw")
stopifnot(dir.exists(raw))

read_object <- function(package, object) {
  env <- new.env(parent = baseenv())
  load(file.path(raw, package, "data", paste0(object, ".rda")), envir = env)
  env[[object]]
}
save_csv <- function(x, name) {
  path <- file.path(out, name)
  write.csv(x, path, row.names = FALSE, na = "NA")
  check <- read.csv(path)
  stopifnot(nrow(check) == nrow(x), identical(names(check), names(x)))
  stopifnot(isTRUE(all.equal(check, x, check.attributes = FALSE, tolerance = 1e-12)))
  invisible(x)
}
to_radians <- function(x) (x %% 360) * pi / 180

# 1. Cylindrical: direction on a circle, speed on a positive real line.
w <- read.table(file.path(raw, "NPCirc/data/speed.wind.txt.gz"), header = TRUE)
stopifnot(nrow(w) == 19488L, all(w$Hour %in% 0:23),
          all(w$Speed > 0, na.rm = TRUE),
          all(w$Direction >= 0 & w$Direction <= 360, na.rm = TRUE))
wind <- data.frame(
  source_row = seq_len(nrow(w)),
  year = w$Year, month = w$Month, day = w$Day, hour = w$Hour,
  speed_m_s = w$Speed,
  direction_deg = w$Direction,
  direction_rad = to_radians(w$Direction)
)
save_csv(wind, "01_galicia_wind.csv")

# 2. Circular bearings aligned to the home direction (0 = 360 degrees).
p <- read_object("circular", "pigeons")
stopifnot(nrow(p) == 108L, !anyNA(p), all(p$bearing >= 0 & p$bearing < 360))
pigeons <- data.frame(
  source_row = seq_len(nrow(p)), treatment = as.character(p$treatment),
  bearing_deg = p$bearing, bearing_rad = to_radians(p$bearing)
)
save_csv(pigeons, "02_homing_pigeons.csv")

# 3. Source values are hours.minutes, NOT decimal hours.
icu_raw <- read_object("circular", "fisherB1")
icu_reference <- as.numeric(read_object("circular", "fisherB1c"))
hour <- floor(icu_raw)
minute <- round(100 * (icu_raw - hour))
decimal_hour <- hour + minute / 60
stopifnot(length(icu_raw) == 254L, all(hour %in% 0:23),
          all(minute %in% 0:59),
          max(abs(decimal_hour - icu_reference)) < 1e-10)
icu <- data.frame(
  source_row = seq_along(icu_raw), source_hours_dot_minutes = icu_raw,
  time_hhmm = sprintf("%02d:%02d", hour, minute),
  decimal_hour = decimal_hour,
  angle_deg = decimal_hour * 15,
  angle_rad = decimal_hour * 2 * pi / 24
)
save_csv(icu, "03_icu_arrival_times.csv")

# 4. Axial data: theta and theta + 180 degrees denote the same axis.
f <- as.numeric(read_object("circular", "fisherB2"))
stopifnot(length(f) == 133L, !anyNA(f), all(f >= 0 & f < 180))
feldspar <- data.frame(
  source_row = seq_along(f), axis_deg = f,
  doubled_angle_deg = (2 * f) %% 360,
  doubled_angle_rad = to_radians(2 * f)
)
save_csv(feldspar, "04_feldspar_orientations.csv")

# 5. Spherical AXES represented by their lower-hemisphere endpoints.
# x and -x denote the same axis; the sign convention is not a cluster.
q <- read_object("boot", "polar")
lat <- q$lat * pi / 180
lon <- q$long * pi / 180
polar <- data.frame(
  source_row = seq_len(nrow(q)), latitude_deg = q$lat,
  longitude_deg = q$long,
  x = cos(lat) * cos(lon), y = cos(lat) * sin(lon), z = sin(lat)
)
stopifnot(nrow(polar) == 50L, !anyNA(polar), all(q$lat < 0),
          max(abs(rowSums(polar[c("x", "y", "z")]^2) - 1)) < 1e-12)
save_csv(polar, "05_paleomagnetic_poles.csv")

# Audit only original analysis variables, not generated IDs/transformations.
audit_one <- function(id, original, angle_columns) {
  data.frame(dataset = id, rows = nrow(original),
             original_variables = ncol(original),
             complete_rows = sum(complete.cases(original)),
             missing_cells = sum(is.na(original)),
             angle_fields = paste(angle_columns, collapse = "; "))
}
audit <- rbind(
  audit_one("01_galicia_wind", w, "Direction"),
  audit_one("02_homing_pigeons", p, "bearing"),
  audit_one("03_icu_arrival_times", data.frame(time = icu_raw), "time"),
  audit_one("04_feldspar_orientations", data.frame(axis = f), "axis"),
  audit_one("05_paleomagnetic_poles", q, c("lat", "long"))
)
save_csv(audit, "validation_summary.csv")
stopifnot(audit$complete_rows[1] == 19206L,
          identical(as.integer(table(p$treatment)[c("c", "on", "v1")]),
                    c(41L, 27L, 40L)))

cat("All five CSV files exported and validated.\n")
print(audit, row.names = FALSE)
cat("\nWind missing values: Speed =", sum(is.na(w$Speed)),
    "; Direction =", sum(is.na(w$Direction)), "\n")
cat("ICU conversion matches the package's separate circular object.\n")
cat("All spherical vectors have unit length within 1e-12.\n")
