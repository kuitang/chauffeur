chauffer
========

Chauffer drives your machine learning (or other) experiments.

We've coded an algorithm, and now we want to test it on some data. This means we have to

 - Choose and _keeping track of_ datasets and parameters
 - Send jobs to cluster machines
 - Monitor cluster jobs
 - Manage program state to restart in the event of machine shutdown
 - Gather and summarizing results

**Chauffer** aims to take care of these messy details so you can focus coding your algorithms, not silly data processing scripts. To use Chauffer, you provide

 - An experiment function that takes as an input a filename, parameter structure, and an optional checkpoint structure (to recover from crashes). It must write results to the specified filename.
 - An _experimental design_ listing the parameters of the function and at what values we want to test them, on which data, and for how many trials. Also, what the experiments output.
 - A summary function to aggregate data from the runs. Chauffer allows your to declaratively specify things like mean and quantiles of the runtimes, and variance of some output with respect to varying certain parameters, etc. Chauffer handles the chores of looping through parameter values and file IO.
 
Chauffer is designed for many runs of expensive functions. Each run may take a long time and may be killed in the middle, so Chauffer supports checkpointing. Because we expect our buggy code to crash, each run is a separate process, and the user is notified of failures. The many runs of an experiment can be done in parallel, across many machines. Chauffer makes this easy by storing all run configurations centrally, and providing a command line which simply takes a design file and a run number--no parameters need to be passed or remembered on the command line.

Chauffer is written in MATLAB and cooperates with the Condor and Moab environments, though neither are required. The main assumption is that if multiple machines are used, source and data files live on a shared filesystem.

For Python, a related (but more intrusive) package is [Python Experiment Suite].

A more detailed workflow: [These are more of design notes for now; replace with a scenario and an example.]

 - Create an _experiment design_, which specifies the function to run, how to summarize the output, and names and values of parameters. The values could vary over a simple grid, or something fancier from a real statistical experimental design. Save it in `expt1/design.mat`.
 - Write a function `exptfun(outfile, params, checkpoint)` which takes input `params` and writes its results to `outfile`. Every output specified in the design must appear in `outfile`, though additional variables are also welcome.
 - Compile with `chauassemble expt1/design`. This function organizes a directory to hold intermediate results. Namely, directories `expt1/<n>` for each of your N runs.
 - Submit jobs of the form `matlab -r chaudrive extp1/design <n>` for each of your n runs to your organization's cluster.
   - As the jobs finish, checkpoints (if any) will collect in `expt1/<n>/checkpoint_<iter>.mat` and results will collect in `expt1/<n>/out.mat`. Chauffer can integrate with Condor's checkpoint mechanism.
 - Once the last run completes, Chauffer will place your summarized output in `expt1/results.mat`.
 - Look/plot/process these results. If you want to analyze your data in a different way, the functions `chaupark` will help you go process your output with minimal hassle. Or, decide to run a different experiment.

# Design of Design
For now, we only support grid designs. A _design_ is just a `.mat` file with two variables, both structures:

 - `params`: Each field is the name of a parameter. The value can be a matrix or cell array. The experiment will be run for each element in the cross product of all of the parameters. Higher dimensional arrays will be treated as flat ones (A(:)).
 - `outputs`: Each field is the name of an output, and the parameter is a function handle which validates the given output, or `[]` which only validates existence. Use this as an opportunity to sanity-check the algorithm's output, given your knowledge of the input parameters.
 - `seed`: A value for the random number generator. `chaudrive` will seed the rng first thing. _None of your code should reseed the random number generator nondeterministically_
 
We will support more advanced statistical experiment designs that apply to computer experiments once we read more about them. Likely, the interface will change. If we find a lot of free time, we might even try implementing Bayesian optimization for parameter search!

Preserving replicability from seeding is tricky, particularly if you call MEX files. You'll just have to be careful. Read a bit.


## Iterative Refinement
After viewing the results of an experiment, we often want to add more points to a certain parameter space. To do so, simply edit the design file and re-run `chauassemble`. Successful runs that only use existing parameter values are kept; runs with new parameter values, or failed runs, are assigned a new id.

`chauassemble` will output a new range of ids for the revised experiment; use those numbers to prepare jobs for cluster submission.

## Dealing with Failed Runs
Runs which don't finish (e.g. crash), or runs which finish but don't pass validation, are declared failed. This is declared in the output file (we always save outputs, so we may, e.g., debug them later), and also in a global index.

Also, we save the last checkpoint to a bug.

 
# Checkpoints and Logs
TODO: File locks in MATLAB? NFS locking issues? Or, pre-specified offset into the global. Or, just use an advisory lock. Or just a simple Java database thingabob.`

## Condor Integration
## Moab Intergration

# Summarizing Data

## Scalar Summaries
Put the stuff in a data table, export to csv, or what have you.

 
# Implementation Details
## Organization of the Experiment Directory

 
[Python Experiment Suite]: http://www.rueckstiess.net/projects/expsuite