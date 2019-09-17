

to_snake_case <- function(x) {
  tolower(gsub('(?<!^)([A-Z])', '_\\1', x, perl = TRUE))
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Specification for all the shapes in Zdog
#'
#' This will be used to
#' \itemize{
#'   \item{build R6 classes}
#'   \item{add methods to the ZdogAnchor class}
#'   \item{create a ztag helper for creating shapes}
#' }
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
shape_specs <- list(
  list(name = 'Rect'       , args = list(width  = NA  , height = NA)),
  list(name = 'RoundedRect', args = list(width  = NA  , height = NA  , cornerRadius = NA)),
  list(name = 'Ellipse'    , args = list(width  = NULL, height = NULL, diameter = NULL)),
  list(name = 'Polygon'    , args = list(radius = 0.5, sides = 3)),
  list(name = 'Shape'      , args = list()),
  list(name = 'Hemisphere' , args = list(diameter = 1            , fill = TRUE)),
  list(name = 'Cone'       , args = list(diameter = 1, length = 1, fill = TRUE)),
  list(name = 'Cylinder'   , args = list(diameter = 1, length = 1, fill = TRUE)),
  list(name = 'Box'        , args = list(width      = 1,
                                         height     = 1,
                                         depth      = 1,
                                         fill       = TRUE,
                                         frontFace  = NULL,
                                         rearFace   = NULL,
                                         leftFace   = NULL,
                                         rightFace  = NULL,
                                         topFace    = NULL,
                                         bottomFace = NULL))
)



#' @rdname ZdogShapeClass
#' @name ZdogRect
#' @export
NULL
#' @rdname ZdogShapeClass
#' @name ZdogRoundedRect
#' @export
NULL
#' @rdname ZdogShapeClass
#' @name ZdogEllipse
#' @export
NULL
#' @rdname ZdogShapeClass
#' @name ZdogPolygon
#' @export
NULL
#' @rdname ZdogShapeClass
#' @name ZdogShape
#' @export
NULL
#' @rdname ZdogShapeClass
#' @name ZdogHemisphere
#' @export
NULL
#' @rdname ZdogShapeClass
#' @name ZdogCone
#' @export
NULL
#' @rdname ZdogShapeClass
#' @name ZdogCylinder
#' @export
NULL
#' @rdname ZdogShapeClass
#' @name ZdogBox
#' @export
NULL


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Convert a named list of arg/value pairs into a character string of formal arguments
#
# if value is NA, then treat as no default
# if NULL, then treat as a literal NULL
# if numeric then treat as a literal numeric
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
list_to_formals_chr <- function(args_list) {
  chars <- c()
  args_list <- append(list('...' = NA), args_list)
  for (i in seq_along(args_list)) {
    name  <- names(args_list)[[i]]
    value <- args_list[[i]]
    if (is.null(value)) {
      arg_string <- paste(name, 'NULL', sep = '=')
    } else if (is.na(value)) {
      arg_string <- name
    } else  if (is.numeric(value) || is.logical(value)) {
      arg_string <- paste(name, value, sep = '=')
    } else {
      stop("no handler for type: ", class(value))
    }

    chars <- c(chars, arg_string)
  }
  paste(chars, collapse = ", ")
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Convert a named list of arguments into the arguments passed to an inner
# function call - passing along all arguments to another function
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
list_to_inner_args_chr <- function(args_list) {
  if (length(args_list) > 0) {
    res <- paste(names(args_list), names(args_list), sep = " = ", collapse = ", ")
  } else {
    res <- NULL
  }
  paste(c('...', res), collapse = ', ')
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create an R6 class for the given spec (i.e. name and args list)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
create_R6_shape_class <- function(spec) {
  new_class <- R6::R6Class(spec$name, inherit = ZdogShapeClass)

  formals_chr    <- list_to_formals_chr(spec$args)
  inner_args_chr <- list_to_inner_args_chr(spec$args)
  inner_args_chr <- paste0(inner_args_chr, ", type='", spec$name, "'")
  method_string <- glue("
function({formals_chr}) {{
  super$initialize({inner_args_chr})
  self
}}")


  method <- eval(parse(text = method_string))
  new_class$set("public", 'initialize', method)
  new_class
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create an R6 class for each of the objects in Zdog
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
for (i in seq_along(shape_specs)) {
  spec <- shape_specs[[i]]
  class_name <- paste0("Zdog", spec$name)
  class_body <- create_R6_shape_class(spec)
  assign(class_name, class_body)
}




#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Add a method to create a new shape directly on an existing anchor class
# object (or subclass of Anchor)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
add_shape_method_to_ZdogAnchor <- function(spec) {
  formals_chr    <- list_to_formals_chr(spec$args)
  inner_args_chr <- list_to_inner_args_chr(spec$args)
  class_name <- paste0("Zdog", spec$name)

  method_string <- glue::glue("
function({formals_chr}) {{
  shape <- {class_name}$new({inner_args_chr})
  self$append(shape)
  invisible(shape)
}}")

  method <- eval(parse(text = method_string))

  ZdogAnchor$set("public", to_snake_case(spec$name), method)
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Add methods for all shapes to the ZdogAnchor class
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
jnk <- lapply(shape_specs, add_shape_method_to_ZdogAnchor)







#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' a helper for initializing Zdog classes
#'
#' @importFrom stats setNames
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ztag <- NULL


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# populate ztag helper
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
add_shape_function_to_ztag <- function(spec) {
  formals_chr    <- list_to_formals_chr(spec$args)
  inner_args_chr <- list_to_inner_args_chr(spec$args)
  class_name <- paste0("Zdog", spec$name)

  method_string <- glue::glue("
function({formals_chr}) {{
  {class_name}$new({inner_args_chr})
}}")

  setNames(list(eval(parse(text = method_string))), to_snake_case(spec$name))
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Add methods for all shapes to the ZdogAnchor class
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ztag <- unlist(lapply(shape_specs, add_shape_function_to_ztag), recursive = FALSE)

























