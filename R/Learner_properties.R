#' Set, add, remove or query properties of learners
#'
#' @template arg_learner
#' @param props [\code{character}]\cr
#'   Vector of properties to set, add, remove or query.
#' @return \code{setProperties}, \code{addProperties} and \code{removeProperties}
#'  return an updated \code{\link{Learner}}.
#'  \code{hasProperties} returns a logical vector of the same length of \code{props}.
#' @export
#' @name LearnerProperties
setProperties = function(learner, props) {
  learner = checkLearner(learner)
  assertCharacter(props, any.missing = FALSE)
  learner$properties = unique(props)
  learner
}

#' @rdname LearnerProperties
#' @export
addProperties = function(learner, props) {
  learner = checkLearner(learner)
  assertCharacter(props, any.missing = FALSE)
  learner$properties = union(learner$properties, props)
  learner
}

#' @rdname LearnerProperties
#' @export
removeProperties = function(learner, props) {
  learner = checkLearner(learner)
  assertCharacter(props, any.missing = FALSE)
  learner$properties = setdiff(learner$properties, props)
  learner
}

#' @rdname LearnerProperties
#' @export
hasProperties = function(learner, props) {
  learner = checkLearner(learner)
  assertCharacter(props, any.missing = FALSE)
  props %in% learner$properties
}