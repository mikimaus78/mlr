#' @export
makeRLearner.regr.kknn = function() {
  makeRLearnerRegr(
    cl = "regr.kknn",
    # FIXME: kknn set its own contr.dummy function, if we requireNamespace,
    # this is not found, see issue  226
    package = "!kknn",
    par.set = makeParamSet(
      makeIntegerLearnerParam(id = "k", default = 7L, lower = 1L),
      makeNumericLearnerParam(id = "distance", default = 2, lower = 0),
      makeDiscreteLearnerParam(id = "kernel", default = "triangular",
        values = list("rectangular", "triangular", "epanechnikov", "biweight", "triweight", "cos", "inv", "gaussian")),
      makeLogicalLearnerParam(id = "scale", default = TRUE)
    ),
    properties = c("numerics", "factors"),
    name = "K-Nearest-Neighbor regression",
    short.name = "kknn",
    note = ""
  )
}

#' @export
trainLearner.regr.kknn = function(.learner, .task, .subset, .weights = NULL,  ...) {
  list(td = .task$task.desc, data = getTaskData(.task, .subset), parset = list(...))
}

#' @export
predictLearner.regr.kknn = function(.learner, .model, .newdata, ...) {
  m = .model$learner.model
  f = getTaskFormula(.model$task.desc)
  pars = c(list(formula = f, train = m$data, test = .newdata), m$parset, list(...))
  m = do.call(kknn::kknn, pars)
  return(m$fitted.values)
}
