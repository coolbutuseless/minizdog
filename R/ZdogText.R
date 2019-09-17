

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @rdname ZdogShapeClass
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ZdogText <- R6::R6Class(
  "ZdogText", inherit = ZdogShapeClass,

  public = list(
    initialize = function(..., value, font = 'default_font', fontSize = 64,
                          textAlign = c('left', 'center', 'right'),
                          textBaseline = c('bottom', 'top', 'middle')) {

      textAlign    <- match.arg(textAlign)
      textBaseline <- match.arg(textAlign)

      super$initialize(...,
                       type         ='Text',
                       value        = value,
                       fontSize     = fontSize,
                       textAlign    = textAlign,
                       textBaseline = textBaseline,
                       font         = font)

      self
    }
  )
)
