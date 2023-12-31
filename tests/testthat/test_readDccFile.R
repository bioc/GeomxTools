
library(GeomxTools)
library(testthat)

datadir <- system.file("extdata", "DSP_NGS_Example_Data",
                       package="GeomxTools")
dccFile <- suppressWarnings(readDccFile(file.path(datadir,  "DSP-1001250002642-E12.dcc")))
lines <- suppressWarnings(trimws(readLines(file.path(datadir,  "DSP-1001250002642-E12.dcc"))))


# Spec 1: test that the names of DCC files have the right formats:------
testthat::test_that("test that the names of DCC files have the right formats", {
  expect_true(all(names(dccFile) == c("Header", "Scan_Attributes", 
                                         "NGS_Processing_Attributes", "Code_Summary")))
  expect_true(all(names(dccFile$Header) == c("FileVersion", "SoftwareVersion", "Date")))
  expect_true(all(names(dccFile$Scan_Attributes) == c("SampleID", "Plate_ID", "Well"))) # QuickBase: "ID", "Plate_ID", "Well"
  expect_true(all(names(dccFile$NGS_Processing_Attributes) == c("SeqSetId", "tamperedIni", "Raw", "Trimmed", "Stitched", "Aligned", "umiQ30",
                                                                "rtsQ30", "DeduplicatedReads")))
  expect_true(all(names(dccFile$Code_Summary) == c("RTS_ID", "Count")))
  expect_true(all(rownames(dccFile$Code_Summary) == dccFile$Code_Summary$RTS_ID))
})



# Spec 2: test that the number of genes is correct:------
testthat::test_that("test that the number of genes is correct", {
  num_genes <- match("</Code_Summary>", lines) - match("<Code_Summary>", lines) - 1
  expect_true(dim(dccFile$Code_Summary)[1] == num_genes)
})



# Spec 3: test that counts are correct:------
testthat::test_that("test that gene counts are correct", {
  cat_counts <- paste(dccFile$Code_Summary$RTS_ID, dccFile$Code_Summary$Count, sep=",")
  expect_true(all(cat_counts %in% lines))
})



