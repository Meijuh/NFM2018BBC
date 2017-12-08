#!/usr/bin/Rscript

library(data.table)
library(ggplot2)
library(tidyr)
library(grid)
library(gridExtra)


args <- commandArgs(trailingOnly = TRUE)

al_files <- dir(args[1], full.names = TRUE, pattern="*.csv")

al_df <- do.call(rbind, lapply(al_files, read.csv))
al_dt <- as.data.table(al_df, keep.rownames = TRUE)
al_dt <- al_dt[order(problem,learner,learnsymbols)]
al_dt[, falsified := 1:.N, by=list(learner,problem)]

bbc_files <- dir(args[2], full.names = TRUE, pattern="*.csv")

bbc_df <- do.call(rbind, lapply(bbc_files, read.csv))
bbc_dt <- as.data.table(bbc_df)
bbc_dt <- bbc_dt[order(problem,learner,learnsymbols)]
bbc_dt[, falsified := 1:.N, by=list(learner,problem)]

dt <- merge(al_dt, bbc_dt, by=c("learner","problem","falsified"), all = TRUE, suffixes=c("_al", "_bbc"))
dt <- dt[order(problem,learner,learnsymbols_bbc)]

write.csv(dt, file="merged-data.csv")

problems <- unique(dt$problem)

g_legend <-function(a.gplot){
	tmp <- ggplot_gtable(ggplot_build(a.gplot))
	leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
	legend <- tmp$grobs[[leg]]
	legend
}

for (p in problems) {
    print(p)
    testdata <- subset(dt, dt$problem == p)
    testdata$eqsymbols_al[testdata$eqsymbols_al == 0] <- 1
    testdata$eqqueries_al[testdata$eqqueries_al == 0] <- 1
    testdata$eqsymbols_bbc[testdata$eqsymbols_bbc == 0] <- 1
    testdata$eqqueries_bbc[testdata$eqqueries_bbc == 0] <- 1

    write.csv(testdata, file = paste("problem-", p, ".csv", sep = ""))

    pdf(paste("learn-", p, ".pdf", sep = ""), height=1.5, width=6, title = paste("Learn - ", p, sep=""))

    graph <- ggplot(data=testdata, aes(y=falsified)) +
        geom_line(aes(x=learnqueries_al, colour=learner), linetype="dashed") +
        geom_line(aes(x=learnqueries_bbc, colour=learner)) +
        labs(y = "#falsified", x = "", colour = "Learner") +
        scale_x_log10() +
        theme(legend.position="none")

    print(graph)
    dev.off()

    pdf(paste("eq-", p, ".pdf", sep = ""), height=1.5, width=6, title = paste("Eq. - ", p, sep=""))

    graph <- ggplot(data=testdata, aes(y=falsified)) +
        geom_line(aes(x=eqqueries_al, colour=learner), linetype="dashed") +
        geom_line(aes(x=eqqueries_bbc, colour=learner)) +
        labs(y = "#falsified", x = "", colour = "Learner") +
        scale_x_log10() +
        theme(legend.position="none") 

    print(graph)
    dev.off()

    pdf(paste("legend-", p, ".pdf", sep=""), width=7.3, height=.4, title="Legend", onefile=FALSE)
    legend <- graph +
        theme(legend.position=c(.5,.5), legend.title=element_blank(), legend.direction="horizontal", legend.text=element_text(size=12))
    legend <- g_legend(legend)
    grid.arrange(legend)
    dev.off()
}

#table_data <- dt
#table_data <- table_data[, list(falsified=max(falsified), learnsymbols=max(learnsymbols), eqsymbols=max(eqsymbols), learnqueries=max(learnqueries), eqqueries=max(eqqueries)), by=list(learner,problem)]
#queries <- data.frame(learner=unique(table_data$learner))
#
#for (p in problems) {
#    print(p)
#    problem_data <- subset(table_data, table_data$problem == p)
#
#    false_count <- max(unlist(problem_data$falsified))
#    print(false_count)
#
#    problem_data <- subset(problem_data, problem_data$falsified == false_count)
#
#    queries <- merge(queries, problem_data[, c("learner", "learnqueries", "eqqueries")], by="learner", all = TRUE)
#    names(queries)[names(queries) == "learnqueries"] = "learnqueries.y"
#    names(queries)[names(queries) == "learnqueries.y"] = paste("learn-", p, sep="")
#    names(queries)[names(queries) == "eqqueries"] = "eqqueries.y"
#    names(queries)[names(queries) == "eqqueries.y"] = paste("eq-", p, sep="")
#
#    problem_data <- subset(df, df$problem == p)dd
#
#}
#
#print(queries)

