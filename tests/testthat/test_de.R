library(lmerTest)
library(stringr)
library(testthat)

datadir <- system.file("extdata", "DSP_NGS_Example_Data", package = "GeomxTools")
demoData <- readRDS(file.path(datadir, "/demoData.rds"))
target_demoData <- aggregateCounts(demoData)
target_demoData <- normalize(target_demoData, norm_method="quant")
target_demoData <- target_demoData[1:100,]
# summary(sData(target_demoData))
pData(target_demoData)[["slide"]]<- factor(pData(target_demoData)[["slide name"]])
protocolData(target_demoData)[["cell_line"]] <- factor(protocolData(target_demoData)[["cell_line"]])
protocolData(target_demoData)[["pool_rep"]] <- factor(protocolData(target_demoData)[["pool_rep"]])

# Run Serial
mixedOuts <- mixedModelDE(target_demoData,
                            elt = "exprs_norm",
                            modelFormula = ~ pool_rep + (1 | slide),
                            groupVar = "pool_rep",
                            nCores = 1,
                            multiCore = FALSE,
                            pAdjust = NULL
)

test_that("test output p-value is as expected", {
# Randomly test one target manually
testTargetExprs <- 
    assayDataElement(target_demoData, elt="exprs_norm")
testTargetExprs <- 
    t(testTargetExprs[sample(nrow(testTargetExprs), 1), , drop=FALSE])
sampleExprs <- data.frame(testTargetExprs, 
                          sData(target_demoData)[, c("pool_rep", "slide")])
target <- names(sampleExprs)[1L]
testMod <- 
    suppressMessages(lmerTest::lmer(paste0(target, " ~ pool_rep + (1 | slide)"), 
                                    sampleExprs))
manualResult <- lmerTest::ls_means(testMod, which="pool_rep", pairwise=TRUE)
expect_equal(mixedOuts["lsmeans", target][[1]][, "Pr(>|t|)"],
             manualResult[, "Pr(>|t|)"])
})

if (Sys.info()['sysname'] != "Windows") {

    test_that("test that the outputs of methods are same", {
    # Run multiple cores, fixed effect and random intercept
    mixedOutmc <- mixedModelDE(target_demoData,
                               elt = "exprs_norm",
                               modelFormula = ~ pool_rep +  (1 | slide),
                               groupVar = "pool_rep",
                               nCores = 2,
                               multiCore = TRUE,
                               pAdjust = NULL
    )

    # Run parallel
    mixedOutp <- mixedModelDE(target_demoData,
                               elt = "exprs_norm",
                               modelFormula = ~ pool_rep +  (1 | slide),
                               groupVar = "pool_rep",
                               nCores = 2,
                               multiCore = FALSE,
                               pAdjust = NULL
    )

    # Spec 1: test that the outputs from mc and serial methods is the same:------
      expect_equal(mixedOutmc, mixedOuts)
    
    # Spec 2: test that the outputs from mc and parallel methods is the same:------
    expect_equal(mixedOutmc, mixedOutp)
    })

    test_that("mixed model function works for random slope and random intercept", {

    # Spec 3. test that function works for model with random slope and random intercept
    design(target_demoData) <- ~ pool_rep + (1 + slide| slide)
    # Run multiple cores
    mixedOutmc <- mixedModelDE(target_demoData,
                               elt = "exprs_norm",
                               modelFormula = NULL,
                               groupVar = "pool_rep",
                               nCores = 2,
                               multiCore = TRUE,
                               pAdjust = NULL
    )

    # Run parallel
    mixedOutp <- mixedModelDE(target_demoData,
                              elt = "exprs_norm",
                              modelFormula = NULL,
                              groupVar = "pool_rep",
                              nCores = 2,
                              multiCore = FALSE,
                              pAdjust = NULL
    )

      expect_equal(mixedOutmc, mixedOutp)
    })


    # Spec 4: test that function outputs an error when model terms are not in sData:------
    # Run parallel
    test_that("test that error when model terms are not in sdata", {
      expect_error(
        mixedOutp <- mixedModelDE(target_demoData,
                                  elt = "exprs_norm",
                                  modelFormula = ~ cell_line +  (1 | fakevar) ,
                                  groupVar = "cell_line",
                                  nCores = 2,
                                  multiCore = FALSE,
                                  pAdjust = NULL)
      )
    })


    # Spec 5: test that function outputs an error when groupVar is not in model formula:------
    # Run parallel
    test_that("test that error when group var not in model", {
      expect_error(
        mixedOutp <- mixedModelDE(target_demoData,
                                  elt = "exprs_norm",
                                  modelFormula = ~ cell_line +  (1 | slide) ,
                                  groupVar = "segment",
                                  nCores = 2,
                                  multiCore = FALSE,
                                  pAdjust = NULL)
      )
    })

}
