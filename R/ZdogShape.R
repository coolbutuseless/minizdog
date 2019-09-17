

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Zdog element builder
#'
#' @import R6
#' @import glue
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ZdogShapeClass <- R6::R6Class(
  "ZdogShapeClass", inherit = ZdogAnchor,

  public = list(

    initialize = function(..., type = 'Shape') {
      super$initialize(type=type, ...)
    },


    color = function(col) {
      self$attribs$color <- paste0("'", col, "'")
      invisible(self)
    },

    stroke = function(width) {
      if (is.logical(width)) {
        self$attribs$stroke <- tolower(as.character(width))
      } else {
        self$attribs$stroke <- width
      }
      invisible(self)
    },

    fill = function(fill_lgl) {
      self$attribs$fill <- tolower(as.character(isTRUE(fill_lgl)))
      invisible(self)
    },

    closed = function(closed_lgl) {
      self$attribs$closed <- tolower(as.character(isTRUE(closed_lgl)))
      invisible(self)
    },

    visible = function(visible_lgl) {
      self$attribs$visible <- tolower(as.character(isTRUE(visible_lgl)))
      invisible(self)
    },

    backface = function(backface_lgl) {
      self$attribs$backface <- tolower(as.character(isTRUE(backface_lgl)))
      invisible(self)
    },

    front = function(...) {
      stop("front not done yet. need generic vector collapse")
    }
)
)



if (FALSE) {
  ZdogShapeClass$new(id = "greg")
}