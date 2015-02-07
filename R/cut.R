#' Bin a vector of air quaility readings into CAAQS management levels
#'
#' Can be used for Ozone, PM2.5 (daily or annual)
#' @param x vector of air quality readings (pollutant concentrations)
#' @param  parameter What is the parameter? Must be one of: \code{"o3", "pm2.5_annual", "pm2.5_daily"}
#' @param  output should the function output labels (\code{"labels"}; default
#'  or break values in unicode (\code{"breaks_u"}) or break values in html (\code{"breaks_h"}), 
#'  or colour values (\code{"colour"} or \code{"color"})?
#' @param  drop_na Should NA values be dropped, or retained as factor level "Insufficient Data" (default)?
#' @export
#' @return factor
#' @examples \dontrun{
#'
#'}
cut_management <- function(x, parameter, output = "labels", drop_na = FALSE) {
  cut_caaq(type = "management", x=x, parameter = parameter, output = output, 
           drop_na = drop_na)
}

#' Bin a vector of air quaility readings into CAAQS achievement levels
#' 
#' Can be used for Ozone, PM2.5 (daily or annual)
#' @param x vector of air quality readings (pollutant concentrations)
#' @param  parameter What is the parameter? Must be one of: \code{"o3", "pm2.5_annual", "pm2.5_daily"}
#' @param  output should the function output labels (\code{"labels"}; default
#'  or break values in unicode (\code{"breaks_u"}) or break values in html (\code{"breaks_h"}), 
#'  or colour values (\code{"colour"} or \code{"color"})?
#' @param  drop_na Should NA values be dropped, or retained as factor level "Insufficient Data" (default)?
#' @export
#' @return factor
#' @examples \dontrun{
#'
#'}
cut_achievement <- function(x, parameter, output = "labels", drop_na = FALSE) {
  cut_caaq(type = "achievement", x=x, parameter = parameter, output = output, 
           drop_na = drop_na)
}

#' @keywords internal
cut_caaq <- function(type, x, parameter, output, drop_na) {
  levels <- get_levels(type, parameter)
  
  breaks <- c(levels$lower_breaks, Inf)
  
  sub_na <- !drop_na && any(is.na(x))
  
  labels <- get_labels(levels, output, sub_na)
  
  if (sub_na) {
    x[is.na(x)] <- -Inf
    x[x == 0] <- 0.0001
    breaks <- c(-Inf, breaks)
  }
  
  cut(x, breaks = breaks, labels = labels, include.lowest = TRUE, right = TRUE, 
      ordered_result = TRUE)
}

#'Return CAAQS levels for any or all, parameters, for either achievement or
#'management reporting
#'
#'@param type one of "achievement", "management"
#'@param parameter one of "all" (default), "o3", "PM2.5_annual", "PM2.5_daily"
#'@export
#'@return A data frame
#' @examples \dontrun{
#' get_levels("o3") 
#'}
get_levels <- function(type, parameter = "all") {
  
  if (type == "achievement") {
    levels <- achievement_levels
  } else if (type == "management") {
    levels <- management_levels
  } else {
    stop("type must be one of achievement or management")
  }
  
  parameter <- tolower(parameter)
  
  match.arg(parameter, c(levels(levels$parameter), "all"))
  
  if (parameter == "all") return(levels)
  
  levels[levels$parameter == parameter, ]
}

#' Get labels
#'
#' @param x dataframe - a subset of achievement_levels or caaqs_levels
#' @param output one of: "labels", "breaks_h", "breaks_u", "colour", "color"
#' @keywords internal
#' @return character vector
get_labels <- function(x, output, sub_na) {
  
  if (!output %in% c("labels", "breaks_h", "breaks_u", "colour", "color")) {
    stop(output, " is not a valid input for output. It must be either 'labels',", 
         "'breaks_u' (for unicode encoding), 'breaks_h' (for html encoding)", 
         " or 'colour' to get hexadecimal colour codes")
  }
  
  if (output == "labels") {
    labels <- x[["labels"]]
  } else if (output == "breaks_u") {
    labels <- x[["val_labels_unicode"]]
  } else if (output == "breaks_h") {
    labels <- x[["val_labels_html"]]
  } else if (output %in% c("colour", "color")) {
    labels <- x[["colour"]]
  }
  
  labels <- as.character(labels)
  
  if (sub_na) {
    if (output %in% c("colour", "color")) {
      labels <- c("#CCCCCC", labels)
    } else {
      labels <- c("Insufficient Data", labels)
    }
  }
  
  labels
}