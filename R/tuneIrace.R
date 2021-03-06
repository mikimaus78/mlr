tuneIrace = function(learner, task, resampling, measures, par.set, control, opt.path, show.info) {
  requirePackages("irace", why = "tuneIrace", default.method = "load")

  #FIXME: allow to do in parallel
  cx = function(x) convertXLogicalsNotAsStrings(x, par.set)
  hookRun = function(instance, candidate, extra.params = NULL, config = list()) {
    rin = instance
    tunerFitnFun(candidate$values, learner = learner, task = task, resampling = rin, measures = measures,
      par.set = par.set, ctrl = control, opt.path = opt.path, show.info = show.info,
      convertx = cx, remove.nas = TRUE)
  }

  n.instances = control$extra.args$n.instances
  control$extra.args$n.instances = NULL
  show.irace.output = control$extra.args$show.irace.output
  control$extra.args$show.irace.output = NULL
  instances = lapply(seq_len(n.instances), function(i) makeResampleInstance(resampling, task = task))
  if (is.null(control$extra.args$digits)) {
    control$extra.args$digits = .Machine$integer.max
  } else {
    control$extra.args$digits = asInt(control$extra.args$digits)
  }

  parameters = convertParamSetToIrace(par.set)
  log.file = tempfile()
  tuner.config = c(list(hookRun = hookRun, instances = instances, logFile = log.file),
    control$extra.args)
  g = if (show.irace.output) identity else capture.output
  g(or <- irace::irace(tunerConfig = tuner.config, parameters = parameters))
  unlink(log.file)
  if (nrow(or) == 0L)
    stop("irace produced no result, possibly the budget was set too low?")
  id = or[1L, 1L]
  # get best candidate
  x1 = as.list(irace::removeCandidatesMetaData(or[1L,]))
  x2 = trafoValue(par.set, x1)
  # we need chars, not factors / logicals, so we can match 'x'
  d = convertDfCols(as.data.frame(opt.path), logicals.as.factor = TRUE)
  d = convertDfCols(d, factors.as.char = TRUE)
  par.names = names(x1)
  # get all lines in opt.path which correspond to x and average their perf values
  j = vlapply(seq_row(d), function(i) isTRUE(all.equal(as.list(d[i, par.names, drop = FALSE]), x1)))
  if (!any(j))
    stop("No matching rows for final elite candidate found in opt.path! This cannot be!")
  y = colMeans(d[j, opt.path$y.names, drop = FALSE])
  # take first index of mating lines to get recommended x
  e = getOptPathEl(opt.path, which.first(j))
  x = trafoValue(par.set, e$x)
  x = removeMissingValues(x)
  if (control$tune.threshold)
    # now get thresholds and average them
    threshold = getThresholdFromOptPath(opt.path, which(j))
  else
    threshold = NULL
  makeTuneResult(learner, control, x, y, threshold, opt.path)
}
