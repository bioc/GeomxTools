#' Get the geometric mean of a vector
#' 
#' @param x numeric vector
#' @param thresh minimum numeric value greater than 0 to have in vector
#' 
#' @return numeric geometric mean of vector
#' 
#' @examples
#' ngeoMean(c(0, 1, 2, 2), thresh=0.1)
#' 
#' @export
#' 
ngeoMean <- function(x, thresh=0.5) {
    x <- thresholdValues(x, thresh=thresh)
    return(EnvStats::geoMean(x, na.rm = TRUE))
}

#' Get the geometric standard deviation of a vector
#' 
#' @param x numeric vector
#' @param thresh minimum numeric value greater than 0 to have in vector
#' 
#' @return numeric geometric standard deviation of vector
#' 
#' @examples
#' ngeoSD(c(0, 1, 2, 2), thresh=0.1)
#' 
#' @export
#' 
ngeoSD <- function(x, thresh=0.5) {
    x <- thresholdValues(x, thresh=thresh)
    return(EnvStats::geoSD(x, na.rm=T))
}

#' Get take the log of a numeric vector
#' 
#' @param x numeric vector
#' @param thresh minimum numeric value greater than 0 to have in vector
#' @param base numeric value indicating base to log with
#' 
#' @return numeric vector with logged values
#' 
#' @examples
#' logtBase(c(0, 1, 2, 2), thresh=0.1, base=10)
#' 
#' @export
#' 
logtBase <- function(x, thresh=0.5, base=2) {
    x <- thresholdValues(x, thresh=thresh)
    return(log(x, base=base))
}

thresholdValues <- function(x, thresh=0.5) {
    if (thresh <= 0) {
      warning("Parameter, thresh, cannot be set to less than or equal to 0. 
              The default threshold of 0.5 was used instead.")
      thresh <- 0.5
    }
    if (min(x, na.rm = TRUE) < thresh) {
        x <- x + thresh
    }
    return(x)
}

#' Add one to all counts in an expression matrix
#' 
#' @param object name of the NanoStringGeoMxSet object
#' @param elt expression matrix element in \code{assayDataElement}
#'        to shift all counts by
#' @param useDALogic boolean to use the same logic in DA (impute 0s to 1s)
#'        or set to FALSE to shift all counts by 1
#' 
#' @return object of NanoStringGeoMxSet class
#' 
#' @examples
#' datadir <- system.file("extdata", "DSP_NGS_Example_Data",
#'                        package="GeomxTools")
#' demoData <- readRDS(file.path(datadir, "/demoData.rds"))
#' shiftCountsOne(demoData)
#' 
#' @export
#' 
shiftCountsOne <- function(object, elt="exprs", useDALogic=FALSE) {
    if (countsShiftedByOne(object)) {
        stop("The exprs matrix has already been shifted by one. ",
             "This operation will not be repeated.")
    }
  
    if(analyte(object) == "Protein"){
      stop("This shift is only meant for RNA data")
    }
    
    assayDataElement(object, "rawZero") <- 
        assayDataElement(object, elt=elt)
    experimentData(object)@other$shiftedByOne <- TRUE
    if (useDALogic) {
        assayDataElement(object, 
                         "exprs")[assayDataElement(object, "exprs") < 1] <- 1
        experimentData(object)@other$shiftedByOneLogic <- 
            "Only zeroes increased by 1 count in exprs matrix"
    } else {
        assayDataElement(object, "exprs") <- 
            assayDataElement(object, elt=elt) + 1
        experimentData(object)@other$shiftedByOneLogic <- 
            "All counts increased by 1 throughout exprs matrix"
    }
    return(object)
}



#' Return the IgG negative controls for protein
#' 
#' @param object name of the NanoStringGeoMxSet object
#' 
#' @return names of IgGs
#' 
#' @export
#' 
iggNames <- function(object){
  if(analyte(object) == "Protein"){
    names <- featureData(object)$Target[featureData(object)$CodeClass == "Negative"]
    return(names)
  }else{
    warning("No Protein data in object so no IgG probes to return")
  }
}

#' Return the House Keeper positive controls for protein
#' 
#' @param object name of the NanoStringGeoMxSet object
#' 
#' @return names of HKs
#' 
#' @export
#' 
hkNames <- function(object){
  if(analyte(object) == "Protein"){
    names <- featureData(object)$Target[featureData(object)$CodeClass == "Control"]
    return(names)
  }else{
    warning("No Protein data in object so no HK probes to return")
  }
}

#### NOT TESTED OR USED ####
collapseCounts <- function(object) {
    probeCounts <- data.table(cbind(fData(object)[, c("TargetName", "Module")],
                                    assayDataElement(object, elt="exprs")))
    collapsedCounts <- probeCounts[, lapply(.SD, ngeoMean), 
                                     by=c("TargetName", "Module")]
    return(collapsedCounts)
}
