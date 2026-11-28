#runs every Command Compendium example on small built-in datasets
#prints one line per example: OK, WARN or ERROR
suppressPackageStartupMessages({
  library(tidyverse); library(sf); library(e1071); library(car); library(spdep); library(spatialreg)
  library(spatstat); library(gstat); library(terra)
})
has <- function(p) requireNamespace(p, quietly = TRUE)
for (p in c("tmap", "gt", "sfdep", "GWmodel", "classInt")) if (has(p)) suppressPackageStartupMessages(library(p, character.only = TRUE))
results <- list()
ok <- function(label, expr, pkgs = character()) {
  miss <- pkgs[!vapply(pkgs, has, logical(1))]
  if (length(miss)) { r <- paste("SKIPPED (not installed:", paste(miss, collapse = ", "), ")") } else {
  r <- tryCatch(withCallingHandlers({ v <- force(expr); if (inherits(v, c("tmap", "gg", "gt_tbl"))) print(v); "OK" },
                 warning = function(w) { if (!grepl("PROJ|cdn.proj|st_centroid assumes|coerced to factor|longitude/latitude|attribute variables are assumed", conditionMessage(w))) results[[label]] <<- paste("WARN:", conditionMessage(w)); invokeRestart("muffleWarning") }),
                error = function(e) paste("ERROR:", conditionMessage(e))) }
  if (is.null(results[[label]]) || r != "OK") results[[label]] <<- r
  cat(sprintf("%-55s %s\n", label, results[[label]]))
}
pdf(NULL)
nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE) |> st_transform(2264) |>
  mutate(rate = SID74 / BIR74 * 1000, nwrate = NWBIR74 / BIR74 * 100, cat = ifelse(BIR74 > 3000, "big", "small"),
         big = ifelse(BIR74 > 3000, 1, 0))
nc$rate[3] <- NA
data.ppp <- NULL; kernel_density <- NULL; ANN_obs <- NULL; nbw <- NULL; fit.ols <- NULL; d <- NULL

## Getting Started
ok("read_csv", { f <- tempfile(fileext = ".csv"); write_csv(st_drop_geometry(nc), f); read_csv(f, show_col_types = FALSE) })
ok("rast(file)", { f <- tempfile(fileext = ".tif"); writeRaster(rast(nrows = 5, ncols = 5, vals = 1:25), f); rast(f) })
ok("load", { f <- tempfile(); x <- 1; save(x, file = f); load(f) })
ok("glimpse/head/nrow/table", { glimpse(nc); head(nc); nrow(nc); table(nc$cat) })

## Basic data manipulation
ok("select/filter/mutate/rename", { nc |> select(NAME, BIR74); nc |> filter(NAME == "Wake" | BIR74 < 2000); nc |> filter(NAME %in% c("Wake", "Ashe"));
  nc |> mutate(x = ifelse(BIR74 > 1000, 1, 0), y = ifelse(big == 1, "big", "small"), diff = BIR79 - BIR74); nc |> rename(births = BIR74) })
ok("drop_na + rows dropped", { complete <- nc |> drop_na(rate, BIR74); stopifnot(nrow(nc) - nrow(complete) == 1) })
ok("distinct()", nc |> st_drop_geometry() |> distinct())
pts <- st_centroid(nc)
dup <- rbind(pts, pts[1:3, ])
ok("filter !duplicated coords", { d <- dup |> filter(!duplicated(st_coordinates(dup))); stopifnot(nrow(d) == 100) })
ok("group_by summarize", nc |> group_by(cat) |> summarize(mean_value = mean(rate, na.rm = TRUE), count = n()))
ok("arrange/slice/pull/distinct/n_distinct", { nc |> arrange(desc(BIR74)); nc |> slice_head(n = 3); nc |> slice_max(BIR74, n = 3); nc |> pull(BIR74); nc |> distinct(cat); nc |> summarize(n_unique = n_distinct(cat)) })
ok("sum/mean logical, table, prop.table", { sum(nc$BIR74 > 3000); mean(nc$BIR74 > 3000); counts <- table(nc$cat, nc$SID74 > 5); prop.table(counts, margin = 1) })
ok("set.seed", set.seed(391))
ok("st_as_sf lon first", { df <- tibble(lon = -79, lat = 35.9); s <- df |> st_as_sf(coords = c("lon", "lat"), crs = 4326); stopifnot(st_coordinates(s)[1, "X"] == -79) })
ok("st_drop_geometry / coords table", { nc |> st_drop_geometry(); data.frame(x = st_coordinates(pts)[, 1], y = st_coordinates(pts)[, 2], value = pts$BIR74) })
ok("st_transform/centroid/buffer/distance/filter/union/geometry", { st_transform(nc, crs = 32119); st_centroid(nc); st_buffer(nc, dist = 5280); st_distance(pts[1:3, ], pts[1:2, ]); pts |> st_filter(nc[1:10, ]); st_union(nc); st_geometry(nc) })

## Descriptive statistics
ok("descriptive stats table (gt)", nc |> st_drop_geometry() |> select(BIR74) |> summarise(n = n(), num_na = sum(is.na(BIR74)), mean = mean(BIR74, na.rm = TRUE), median = median(BIR74, na.rm = TRUE), sd = sd(BIR74, na.rm = TRUE), variance = var(BIR74, na.rm = TRUE), mean_dev = mean(abs(BIR74 - mean(BIR74, na.rm = TRUE)), na.rm = TRUE), cv = sd / mean, min = min(BIR74, na.rm = TRUE), max = max(BIR74, na.rm = TRUE), skewness = skewness(BIR74, na.rm = TRUE), kurtosis = kurtosis(BIR74, na.rm = TRUE)) |>
  pivot_longer(everything(), names_to = "Statistic", values_to = "Value") |> gt() |> tab_header(title = "TITLE") |> fmt_number(columns = Value, decimals = 2), "gt")
ok("OLD: fmt_number(columns = everything())", nc |> st_drop_geometry() |> summarise(n = n(), mean = mean(BIR74)) |> pivot_longer(everything(), names_to = "Statistic", values_to = "Value") |> gt() |> fmt_number(columns = everything(), decimals = 2), "gt")
ok("categorical table (gt)", nc |> st_drop_geometry() |> group_by(cat) |> summarise(n = n()) |> gt(), "gt")
ok("kurtosis is excess", { set.seed(1); stopifnot(abs(kurtosis(rnorm(1e5))) < 0.1) })
g <- nc |> st_drop_geometry() |> group_by(cat) |> summarise(Count = n())
ok("histogram", ggplot(nc, aes(x = BIR74)) + geom_histogram(binwidth = 1000, fill = "lightgrey", color = "black", alpha = 0.7) + labs(title = "T", x = "X", y = "Y"))
ok("boxplot", ggplot(nc, aes(y = BIR74)) + geom_boxplot(fill = "lightgrey") + labs(title = "T", y = "Y"))
ok("violin", ggplot(nc, aes(x = 1, y = BIR74)) + geom_violin(fill = "lightgrey", bw = 1.2) + geom_boxplot(width = 0.1) + labs(title = "T", y = "Y") + theme(axis.title.x = element_blank(), axis.text.x = element_blank(), axis.ticks.x = element_blank()))
ok("bar chart geom_col", ggplot(g, aes(x = cat, y = Count)) + geom_col() + coord_flip() + labs(x = "X", y = "Y"))
ok("scatterplot + lm line", ggplot(nc, aes(x = BIR74, y = SID74)) + geom_point() + geom_smooth(method = "lm", se = FALSE, color = "black", formula = y ~ x) + labs(x = "X", y = "Y"))
ok("density/line/ecdf", { print(ggplot(nc, aes(x = BIR74)) + geom_density(fill = "lightgrey")); print(ggplot(nc, aes(x = BIR74, y = SID74)) + geom_line()); ggplot(nc, aes(x = BIR74)) + stat_ecdf() })
ok("vline + breaks", ggplot(nc, aes(x = SID74)) + geom_histogram(binwidth = 1) + geom_vline(xintercept = 5, linetype = "dashed") + scale_x_continuous(breaks = 0:44))

## Maps
ok("point map intervals", tm_shape(pts) + tm_dots(fill = "BIR74", size = 0.5, fill.scale = tm_scale_intervals(values = "brewer.blues", style = "quantile", n = 5)), "tmap")
ok("polygon map styles", { for (s in c("equal", "fisher", "pretty", "quantile")) print(tm_shape(nc) + tm_polygons(fill = "BIR74", fill.scale = tm_scale_intervals(values = "brewer.blues", style = s, n = 5))); "x" }, "tmap")
ok("tmap_mode view/plot", { tmap_mode(mode = "view"); tmap_mode(mode = "plot") }, "tmap")
ok("tm_title / fill_alpha", tm_shape(nc) + tm_polygons(fill = "BIR74", fill_alpha = 0.5) + tm_title("TITLE"), "tmap")
ok("tm_legend title", tm_shape(nc) + tm_polygons(fill = "BIR74", fill.legend = tm_legend(title = "LEGEND")), "tmap")
ok("reversed palette", tm_shape(nc) + tm_polygons(fill = "BIR74", fill.scale = tm_scale_intervals(values = "-brewer.rd_yl_bu", style = "quantile", n = 5)), "tmap")
ok("midpoint = 0", { nc$res <- nc$BIR74 - mean(nc$BIR74); tm_shape(nc) + tm_polygons(fill = "res", fill.scale = tm_scale_intervals(values = "brewer.rd_bu", style = "pretty", midpoint = 0)) }, "tmap")
ok("col_alpha = 0", tm_shape(nc) + tm_polygons(fill = "BIR74", col_alpha = 0), "tmap")
ok("categorical named colors", tm_shape(nc) + tm_polygons(fill = "cat", fill.scale = tm_scale_categorical(values = c("big" = "#B2182B", "small" = "#2166AC"))), "tmap")
ok("classIntervals + cut", { b <- classInt::classIntervals(na.omit(nc$BIR74), n = 5, style = "quantile")$brks; table(cut(nc$BIR74, b, include.lowest = TRUE)) }, "classInt")
ok("categorical brewer.set2", tm_shape(nc) + tm_polygons(fill = "cat", fill.scale = tm_scale_categorical(values = "brewer.set2")), "tmap")
ok("tm_symbols", tm_shape(nc) + tm_symbols(size = "BIR74", fill = "BIR74"), "tmap")
r <- rast(vect(nc), resolution = 20000); values(r) <- runif(ncell(r))
ok("tm_raster carto.sunset_dark", tm_shape(r) + tm_raster(col.scale = tm_scale_intervals(values = "carto.sunset_dark", n = 5)), "tmap")
ok("tm_borders", tm_shape(nc) + tm_borders(), "tmap")
ok("bivariate", tm_shape(nc) + tm_polygons(fill = tm_vars(c("BIR74", "SID74"), multivariate = TRUE), fill.scale = tm_scale_bivariate(values = "bivario.folk_warmth", scale1 = tm_scale_intervals(n = 4, style = "quantile"), scale2 = tm_scale_intervals(n = 4, style = "quantile"))), "tmap")
ok("tm_basemap CartoDB (plot needs maptiles)", tm_shape(nc) + tm_polygons(fill_alpha = 0.5) + tm_basemap("CartoDB.PositronNoLabels"), c("tmap", "maptiles"))
ok("tm_add_legend", tm_shape(nc) + tm_polygons() + tm_add_legend(type = "symbols", labels = "LABEL", fill = "red"), "tmap")
ok("tmap_arrange", { m1 <- tm_shape(nc) + tm_polygons(fill = "BIR74"); m2 <- tm_shape(nc) + tm_polygons(fill = "BIR79"); print(tmap_arrange(m1, m2, ncol = 2)); "x" }, "tmap")
ok("c4a_gui exists", stopifnot(is.function(cols4all::c4a_gui)), "cols4all")

## Descriptive spatial statistics
ok("center_mean / weighted", { c1 <- center_mean(pts); c2 <- center_mean(pts, weights = pts$BIR74); st_distance(c1, c2) / 5280 }, "sfdep")
ok("OLD: center_mean(weight =)", center_mean(pts, weight = pts$BIR74), "sfdep")
ok("std_dev_ellipse + st_ellipse", { e <- std_dev_ellipse(pts); st_ellipse(geometry = e, sx = e$sx, sy = e$sy, rotation = -e$theta) }, "sfdep")
ok("std_dev_ellipse has no weights arg", stopifnot(!"weights" %in% names(formals(std_dev_ellipse))), "sfdep")

## Probability
ok("empirical probability", { mean(nc$BIR74 > 3000); sum(nc$big) / nrow(nc) })
ok("binomial", { N <- 10; p <- 0.3; t <- tibble(num_successes = 0:N, probability = dbinom(x = 0:N, size = N, prob = p)); t |> slice_max(probability); pbinom(3, size = N, prob = p); 1 - pbinom(3, size = N, prob = p) })
ok("pnorm", pnorm(3000, mean = mean(nc$BIR74), sd = sd(nc$BIR74)))
ok("histogram + normal curve, qq", { print(ggplot(nc, aes(x = BIR74)) + geom_histogram(aes(y = after_stat(density)), binwidth = 1000, fill = "lightgrey") + stat_function(fun = dnorm, args = list(mean = mean(nc$BIR74), sd = sd(nc$BIR74)))); qqnorm(nc$BIR74); qqline(nc$BIR74) })

## Estimation
ok("t.test CI matches by hand", { tt <- t.test(nc$BIR74, conf.level = 0.95); x_bar <- mean(nc$BIR74); s <- sd(nc$BIR74); n <- nrow(nc); m <- qt(0.975, df = n - 1) * s / sqrt(n); stopifnot(isTRUE(all.equal(as.numeric(tt$conf.int), c(x_bar - m, x_bar + m)))) })
ok("prop.test + by hand", { prop.test(sum(nc$big), nrow(nc), conf.level = 0.95); p_hat <- sum(nc$big) / nrow(nc); pm <- qnorm(0.975) * sqrt(p_hat * (1 - p_hat) / nrow(nc)); c(p_hat - pm, p_hat + pm) })
ok("qnorm/qt", c(qnorm(0.975), qt(0.975, df = 99)))
ok("sample/replicate", { sample(nc$BIR74, size = 10, replace = TRUE); replicate(20, mean(sample(nc$BIR74, size = 10, replace = TRUE))) })
ok("raster to data frame", { d <- as.data.frame(r); names(d) <- "VARIABLE"; mean(d$VARIABLE) })

## Hypothesis testing
ok("one-sample t", t.test(nc$BIR74, mu = 3000, alternative = "less", conf.level = 0.95))
ok("leveneTest + two-sample t + effect", { leveneTest(BIR74 ~ cat, data = nc); tt <- t.test(SID74 ~ cat, data = nc, var.equal = TRUE); tt$estimate; diff(tt$estimate) })
ok("paired t", t.test(nc$BIR79, nc$BIR74, paired = TRUE, alternative = "greater", conf.level = 0.95))
ok("chi-square + expected", { ct <- chisq.test(table(nc$cat, nc$SID74 > 5)); ct$expected })

## Point pattern analysis
set.seed(391)
P <- st_sf(geometry = st_sample(st_union(nc), 150))
P <- rbind(P, P[1:3, ])
ok("as.owin(st_union) + as.ppp(st_geometry)", { boundary_owin <- as.owin(st_union(nc)); data.ppp <- as.ppp(st_geometry(P), W = boundary_owin) })
ok("rescale feet to miles", data.ppp <- spatstat.geom::rescale(data.ppp, 5280, "mile"))
ok("rescale() with terra loaded", rescale(data.ppp, 5280, "mile"))
ok("unique / rjitter", { stopifnot(npoints(unique(data.ppp)) == 150); rjitter(data.ppp, radius = 0.01); data.ppp <- unique(data.ppp) })
ok("quadratcount + plot + VMR + test", { q <- quadratcount(data.ppp, nx = 3, ny = 3); plot(data.ppp, pch = 16, cex = 0.5); plot(q, add = TRUE, col = "black"); var(as.vector(q)) / mean(as.vector(q)); quadrat.test(data.ppp, nx = 3, ny = 3, method = "MonteCarlo", nsim = 999) })
ok("intensity area.owin(Window())", npoints(data.ppp) / area.owin(Window(data.ppp)))
ok("area() with terra loaded", npoints(data.ppp) / area(Window(data.ppp)))
ok("kernel density + plot", { kernel_density <- density(data.ppp); plot(kernel_density, main = "T"); plot(data.ppp, add = TRUE, pch = 16, cex = 0.5) })
ok("ANN ratio + clarkevans", { ANN_obs <- mean(nndist(data.ppp)); e <- 0.5 / sqrt(npoints(data.ppp) / area.owin(Window(data.ppp))); ANN_obs / e; clarkevans.test(data.ppp, correction = "none", alternative = "two.sided", method = "MonteCarlo", nsim = 999) })
ok("ANN inhomogeneous loop", { nsim <- 99; s <- numeric(nsim); for (i in 1:nsim) s[i] <- mean(nndist(rpoispp(kernel_density))); g <- sum(s >= ANN_obs); 2 * min((g + 1) / (nsim + 1), (nsim - g + 1) / (nsim + 1)) })
ok("L-function Lest CSR", { e <- envelope(data.ppp, fun = Lest, nsim = 19, correction = "border", transform = expression(. - r), verbose = FALSE); plot(e) })
ok("OLD: Linhom envelope simulates CSR?", { e <- envelope(data.ppp, fun = Linhom, nsim = 19, funargs = list(correction = "border"), transform = expression(. - r), verbose = FALSE); if (isTRUE(attr(e, "einfo")$csr)) stop("simulations are CSR, not inhomogeneous") })
ok("L-function Linhom with simulate", { e <- envelope(data.ppp, fun = Linhom, nsim = 19, simulate = expression(rpoispp(kernel_density)), funargs = list(lambda = kernel_density, correction = "border"), transform = expression(. - r), verbose = FALSE); stopifnot(!isTRUE(attr(e, "einfo")$csr)); plot(e) })

## Autocorrelation and modeling
ncc <- nc |> filter(!is.na(rate))
ok("poly2nb + nb2listw zero.policy + summary + plot", { nb <- poly2nb(ncc, queen = TRUE); nbw <- nb2listw(nb, style = "W", zero.policy = TRUE); summary(nb); plot(st_geometry(ncc), border = "grey"); plot(nb, st_coordinates(st_centroid(st_geometry(ncc))), add = TRUE) })
ok("dnearneigh on polygons", dnearneigh(ncc, d1 = 0, d2 = 150000))
ok("dnearneigh on centroids", nb2listw(dnearneigh(st_centroid(ncc), d1 = 0, d2 = 150000), style = "W", zero.policy = TRUE))
ok("knearneigh on polygons", knearneigh(ncc, k = 6))
ok("knearneigh on centroids", nb2listw(knn2nb(knearneigh(st_centroid(ncc), k = 6)), style = "W"))
ok("moran.test / moran.mc / moran.plot", { moran.test(ncc$rate, nbw); set.seed(391); moran.mc(ncc$rate, nbw, nsim = 999); moran.plot(ncc$rate, nbw, xlab = "X", ylab = "Y") })
ok("LISA new", { set.seed(391); li <- localmoran_perm(ncc$rate, nbw, nsim = 999); head(li); d <- ncc |> mutate(lisa_p = li[, "Pr(z != E(Ii)) Sim"], lisa_quad = as.character(attr(li, "quadr")$mean), lisa_cluster = ifelse(lisa_p < 0.05, lisa_quad, "Not significant")); print(table(d$lisa_cluster)); d <- d })
ok("LISA map", tm_shape(d) + tm_polygons(fill = "lisa_cluster", fill.scale = tm_scale_categorical(values = c("High-High" = "#B2182B", "Low-Low" = "#2166AC", "High-Low" = "#F4A582", "Low-High" = "#92C5DE", "Not significant" = "#E5E5E5")), fill.legend = tm_legend(title = "LISA cluster")), "tmap")
ok("OLS + resid", { fit.ols <- lm(rate ~ nwrate + BIR74, data = ncc); summary(fit.ols); ncc <- ncc |> mutate(residuals = resid(fit.ols)) })
ok("lm.morantest", lm.morantest(fit.ols, nbw))
ok("lm.RStests", lm.RStests(fit.ols, nbw, test = c("RSerr", "RSlag", "adjRSerr", "adjRSlag")))
ok("lag/error/AIC/moran resid", { fl <- lagsarlm(rate ~ nwrate + BIR74, data = ncc, listw = nbw); summary(fl); fe <- errorsarlm(rate ~ nwrate + BIR74, data = ncc, listw = nbw); summary(fe); print(AIC(fit.ols, fl, fe)); moran.test(residuals(fe), nbw) })
ok("GWR bw.gwr + gwr.basic on sf", { bw <- bw.gwr(rate ~ nwrate + BIR74, data = ncc, approach = "AICc", kernel = "bisquare", adaptive = TRUE); fg <- gwr.basic(rate ~ nwrate + BIR74, data = ncc, bw = bw, kernel = "bisquare", adaptive = TRUE); print(fg); gr <- st_as_sf(fg$SDF); stopifnot(all(c("nwrate", "Local_R2") %in% names(gr))); print(tm_shape(gr) + tm_polygons(fill = "nwrate")); tm_shape(gr) + tm_polygons(fill = "Local_R2") }, c("GWmodel", "tmap"))
ok("k-means elbow + profiles", { cv <- ncc |> st_drop_geometry() |> select(BIR74, SID74, NWBIR74, rate) |> scale(); set.seed(391); wss <- sapply(1:10, function(k) kmeans(cv, centers = k, nstart = 25)$tot.withinss); print(ggplot(data.frame(k = 1:10, wss = wss), aes(x = k, y = wss)) + geom_line() + geom_point() + labs(x = "N", y = "W")); km <- kmeans(cv, centers = 4, nstart = 25); dd <- ncc |> mutate(cluster = as.character(km$cluster)); dd |> st_drop_geometry() |> group_by(cluster) |> summarise(across(c(BIR74, SID74, NWBIR74, rate), mean), n = n()) })

## Continuous surfaces
data(meuse, package = "sp")
m <- st_as_sf(meuse, coords = c("x", "y"), crs = 28992); m$VARIABLE <- log(m$zinc)
BOUNDARY <- st_sf(geometry = st_buffer(st_convex_hull(st_union(m)), 50))
DATA_df <- NULL; grid <- NULL; idw_surface <- NULL; krige_surface <- NULL; v <- NULL; vgm_fit <- NULL
ok("coords table + grid", { DATA_df <- data.frame(x = st_coordinates(m)[, 1], y = st_coordinates(m)[, 2], value = m$VARIABLE); grid <- rast(vect(BOUNDARY), resolution = 50) })
ok("IDW gstat + interpolate + mask", { im <- gstat(formula = value ~ 1, locations = ~x + y, data = DATA_df, set = list(idp = 2)); s <- interpolate(grid, im, debug.level = 0); idw_surface <- mask(s, vect(BOUNDARY)) })
ok("IDW map", tm_shape(idw_surface[["var1.pred"]]) + tm_raster(col.scale = tm_scale_intervals(style = "quantile", n = 5, values = "-brewer.rd_yl_bu")), "tmap")
ok("variogram + show.vgms + fit", { v <- variogram(value ~ 1, locations = ~x + y, data = DATA_df); plot(v); print(show.vgms()); vgm_fit <- fit.variogram(v, vgm("Sph")); vgm_fit; fit.variogram(v, vgm(psill = 0.6, model = "Sph", range = 900, nugget = 0.05)); print(plot(v, vgm_fit)) })
ok("krige.cv IDW + kriging + RMSE", { cv <- krige.cv(value ~ 1, locations = ~x + y, data = DATA_df, set = list(idp = 2), verbose = FALSE); sqrt(mean(cv$residual^2)); cv <- krige.cv(value ~ 1, locations = ~x + y, data = DATA_df, model = vgm_fit, verbose = FALSE); sqrt(mean(cv$residual^2)) })
ok("kriging surface + variance", { km <- gstat(formula = value ~ 1, locations = ~x + y, data = DATA_df, model = vgm_fit); s <- interpolate(grid, km, debug.level = 0); krige_surface <- mask(s, vect(BOUNDARY)); stopifnot(all(c("var1.pred", "var1.var") %in% names(krige_surface))) })
ok("kriging maps", { print(tm_shape(krige_surface[["var1.pred"]]) + tm_raster()); tm_shape(krige_surface[["var1.var"]]) + tm_raster() }, "tmap")
ok("extract mean by polygon", { POLYGONS <- st_sf(geometry = st_make_grid(BOUNDARY, n = c(2, 2))); pm <- terra::extract(krige_surface[["var1.pred"]], vect(POLYGONS), fun = mean, na.rm = TRUE); POLYGONS <- POLYGONS |> mutate(mean_pred = pm$var1.pred); stopifnot(nrow(pm) == nrow(POLYGONS)) })

cat("\nSUMMARY\n"); print(table(sub(":.*| \\(.*", "", unlist(results))))
for (n in names(results)) if (!startsWith(results[[n]], "OK")) cat(sprintf("%-55s %s\n", n, results[[n]]))
