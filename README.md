# Sound Black-Box Checking in the LearnLib

This README first explains how to install several Maven projects required to
run the benchmarks. Next it will explain where to find all data and re-analyze
the data.

## Compiling

To reproduce our benchmarks it is required to install four Maven projects.

1. A new version of the AutomataLib: https://github.com/Meijuh/automatalib.
1. A new version of the LearnLib: https://github.com/Meijuh/learnlib.
1. Our modified RERS 2017 Problems: https://github.com/Meijuh/RERS2017-seq-problems.
1. Our SUL implementation for the RERS 2017 problems: https://github.com/Meijuh/RERS2017.

All Maven projects may be installed with `mvn install`. However it may be the
case that for https://github.com/Meijuh/RERS2017-seq-problems the java compiler
runs out of memory. This can be resolved by using e.g. `export
MAVEN_OPTS="-Xmx13g -Xms10g"`.

The Maven project at https://github.com/Meijuh/RERS2017 also contains an extra
target `mvn compile assembly:single`. This is convienient for creating a jar
file that contains all dependencies. Once this jar file is built, run `java -cp
.:target/nl.utwente.fmt.rersExperiment.2017-1.0-SNAPSHOT-jar-with-dependencies.jar
nl.utwente.fmt.rers.Main`. This should output usage information:

    usage: java nl.utwente.fmt.rers.Main [problem number] [learner]
     -d,--disprove-first          use disprove first black-box oracle
     -h,--help                    prints help
     -l,--learn-first <arg>       learn first within a timeout in seconds
     -m,--multiplier <arg>        multiplier for unrolls
     -r,--no-random-words         do not use an additional random words
                                  equivalence oracle
     -u,--minimum-unfolds <arg>   minimum number of unfolds

Mandatory parameters are `problem number` indicating the RERS problem number,
which ranges from 1-9, and the `learner` which should be any of `{ADT, DHC,
DiscriminationTree, KearnsVazirani, ExtensibleLStar, MalerPnueli,
RivestSchapire, TTT}`.

So running `java -cp
.:target/nl.utwente.fmt.rersExperiment.2017-1.0-SNAPSHOT-jar-with-dependencies.jar
nl.utwente.fmt.rers.Main 1 TTT` performs black-box checking with *state
equivalence* checks. On standard output one can find CSV output of properties
falsified, and standard error logging information can be found.

The CSV columns are as follows:

* problem: the problem number,
* learner: the learning algorithm,
* property: the property number falsified,
* fixed: the number of times the property was falsified by not using state equivalence checks and unrolling the loop a fixed number of times,
* relative: the number of times the property was falsified by not using state equivalence checks and unrolling the loop a relative number of times,
* size: the size of the hypothesis used to disprove the property,
* learnsymbols: the accumulative number of symbols the learner used to disprove the property,
* eqsymbols: the accumulative number of symbols the equivalence oracle used to disprove the property,
* emsymbols: the accumulative number of symbols the emptiness oracle used to disprove the property,
* isymbols: the accumulative number of symbols the inclusion oracle used to disprove the property,
* learnqueries: the accumulative number of queries the learner used to disprove the property,
* eqqueries: the accumulative number of queries the equivalence oracle used to disprove the property,
* emqueries: the accumulative number of queries the emptiness oracle used to disprove the property,
* iqueries: the accumulative number of queries the inclusion oracle used to disprove the property.

On standard error the following logging error can be found:

1. first all LTL formulae are printed,
1. spurious counterexamples used to refine the hypotheses,
1. omega-queries that disprove certain LTL formulae.

## Analyzing data

The graphs from all our experiments can be found in the folder `pdf`. Files
named `learn-<n>.pdf` show the number of learning queries required for problem
`n`. Files named `eq-<n>.pdf` show the number of equivalence queries required
for problem `n`.

All data for the active learning experiments can be found in the folder `al`.
All the data for the black-box checking experiments can be found in the folder
`bbc`. In both cases the directories contain files with extension `.log`, and
`.csv`.  The `.log` files contain the logging data from standard error, and
`.csv` contains the CSV data printed on standard out.

To generate all the graphs manually run `analyze.r al bbc`. This will
generate files in the working directory. Note that to run `analyze.r` `R` is
required with a few dependencies such as `ggplot2`.

