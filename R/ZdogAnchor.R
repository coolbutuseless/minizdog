

collapse_vector <- function(x = NULL, y = NULL, z = NULL) {
  vec <- c(x = x, y = y, z = z)
  vec <- Filter(Negate(is.null), vec)
  res <- paste(names(vec), unlist(vec), sep = ": ", collapse = ", ")
  res <- paste("{", res, "}")
  res
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Generate some nicer looking ID strings
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IDGenerator <- R6::R6Class(
  "IDGenerator",

  public = list(
    count = NULL,

    initialize = function() {
      self$count <- list()
    },

    next_id = function(prefix = 'zdog') {
      if (prefix %in% names(self$count)) {
        self$count[[prefix]] <- self$count[[prefix]] + 1L
      } else {
        self$count[[prefix]] <- 1L
      }
      sprintf("%s%02i", prefix, self$count[[prefix]])
    }
  )
)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Zdog element builder
#'
#' @import R6
#' @import glue
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ZdogAnchor <- R6::R6Class(
  "ZdogAnchor",

  public = list(

    id_gen   = IDGenerator$new(),
    id       = NULL,
    type     = NULL,
    attribs  = NULL,
    children = NULL,

    initialize = function(..., type = 'Anchor') {
      self$type     <- type
      self$update_id()

      self$attribs  <- list()
      self$children <- list()

      self$update(...)

      self
    },

    update_id = function(recursive = FALSE) {
      self$id <- self$id_gen$next_id(self$type)

      if (recursive) {
        for (child in self$children) {
          child$attribs$addTo <- self$id
          child$update_id(recursive = TRUE)
        }
      }
      invisible(self)
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Update the HTML Element.
    #   - Named arguments are considered attributes and will overwrite
    #     existing attributes with the same name. Set to NULL to delete the attribute
    #   - Unnamed arguments are appended to the list of child nodes.  These
    #     should be text, other ZdogAnchors or any ojbect that can be represented
    #     as a single text string using "as.character()"
    #   - to print just the attribute name, but without a value, set to NA
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    update = function(...) {
      varargs      <- list(...)
      if (length(varargs) == 0) {
        return(invisible(self))
      }

      vararg_names <- names(varargs)
      if (is.null(vararg_names)) {
        vararg_names <- character(length = length(varargs))
      }
      has_name   <- nzchar(vararg_names)

      children <- varargs[!has_name]
      attribs  <- varargs[ has_name]

      self$attribs  <- modifyList(self$attribs, attribs, keep.null = FALSE)
      do.call(self$append, children)

      invisible(self)
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Insert a child node. by default at the end of the list of children nodes
    # but 'position' argument can be used to set location
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    append = function(..., position = NULL) {
      child_objects <- list(...)

      for (x in child_objects) {
        x$update(addTo = self$id)
      }

      if (is.null(position)) {
        self$children <- append(self$children, child_objects)
      } else {
        self$children <- append(self$children, child_objects, after = position - 1)
      }

      invisible(self)
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # create an HTML element and add it to the document. return the newly
    # created element
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    add = function(name, ...) {
      if (!is.character(name)) {
        stop("ZdogAnchor$add(): 'name' must be a character string")
      }
      new_elem <- ZdogAnchor$new(name, ...)
      self$append(new_elem)
      invisible(new_elem)
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Remove child objects at the given indicies
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    remove_indices = function(indicies) {
      self$children[indices] <- NULL
      inviisible(self)
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursively convert this XMLElement and children to text and concatenate
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    as_character_inner = function(..., depth = 0) {
      indent1   <- create_indent(depth)
      indent2   <- create_indent(depth + 1)

      value_attribs <- self$attribs

      # Convert all to character
      value_attribs <- lapply(value_attribs, function(x) {
        if (is.logical(x)) {
          tolower(as.character(isTRUE(x)))
        } else if (inherits(x, 'ZdogAnchor')) {
          x$id
        } else {
          x
        }
      })

      # names of colours should be quoted
      quoted_attributes <- c('element', 'color', 'value', 'textAlign', 'textBaseline')
      for (attr_name in quoted_attributes) {
        if (attr_name %in% names(value_attribs)) {
          value_attribs[[attr_name]] <- sQuote(value_attribs[[attr_name]], FALSE)
        }
      }

      if (length(value_attribs) > 0) {
        attr_names <- paste0(indent2, names(value_attribs))
        value_attribs <- paste(attr_names,
                               unlist(value_attribs),
                               sep = ": ", collapse = ",\n")
        # value_attribs <- paste0(value_attribs, ",")
      } else {
        value_attribs <- NULL
      }

      attribs <- value_attribs
      open    <- glue::glue("{indent1}let {self$id} = new Zdog.{self$type}({{")
      close   <- glue::glue("{indent1}}});")

      if (length(self$children) > 0) {
        children <- lapply(self$children, as.character, depth = depth + 1)
        children <- unlist(children, use.names = FALSE)
      } else {
        children = NULL
      }

      c(open, value_attribs, close, children)
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursively convert this XMLElement and children to text and concatenate
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    as_character = function(..., depth = 0) {
      zdog_string <- paste0(self$as_character_inner(depth = depth), collapse = "\n")

      zdog_string
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Print the HTML string
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    print = function(...) {
      cat(self$as_character(...))
      invisible(self)
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Save HTML fragment
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    save = function(filename, ...) {
      writeLines(self$as_character(...), filename)
      invisible(self)
    },


    addTo = function(x) {
      if (inherits(x, "ZdogAnchor")) {
        self$attribs$addTo <- x$id
      } else {
        self$attribs$addTo <- as.character(x)
      }
      invisible(self)
    },

    translate = function(x=NULL, y=NULL, z=NULL) {
      self$attribs$translate <- collapse_vector(x = x, y = y, z = z)
      invisible(self)
    },

    rotate = function(x = NULL, y = NULL, z = NULL) {
      if (!is.null(x)) {
        self$attribs$rotate <- collapse_vector(x = x)
      } else if (!is.null(y)) {
        self$attribs$rotate <- collapse_vector(y = y)
      } else if (!is.null(z)) {
        self$attribs$rotate <- collapse_vector(z = z)
      }
      invisible(self)
    },

    scale = function(x, y = NULL, z = NULL) {
      self$attribs$scale <- collapse_vector(x = x, y = y, z = z)
      invisible(self)
    },

    addChild = function(x) {
      self$append(x)
      invisible(self)
    },

    removeChild = function(x) {
      warning("removeChild() does not currently have any effect")
      invisible(self)
    },

    remove = function() {
      warning("remove() does not currently have any effect")
      invisible(self)
    },

    updateGraph = function() {
      warning("updateGraph() does not currently have any effect")
      invisible(self)
    },

    renderGraphCanvas = function() {
      warning("renderGraphCanvas() does not currently have any effect")
      invisible(self)
    },

    renderGraphSvg = function(...) {
      warning("renderGraphSvg() does not currently have any effect")
      invisible(self)
    },

    normalizeRotate = function() {
      warning("normalizeRotate() does not currently have any effect")
      invisible(self)
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Shallow copy just this element. and empty out the children list.
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    copy = function() {
      new <- self$clone(deep = FALSE)
      new$update_id()
      new$children <- list()
      new
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Deep copy needed as 'children' is a list of R6 objects.
    # update this ID and cascade an ID/addTo update across all children
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    copyGraph = function() {
      new <- self$clone(deep = TRUE)
      new$update_id(recursive = TRUE)
      new
    }
  ),


  private = list(
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # When called with `$clone(deep = TRUE)`, the 'deep_clone' function is
    # called for every name/value pair in the object.
    # See: https://r6.r-lib.org/articles/Introduction.html
    # Need special handling for:
    #   - 'children' is a list of R6 objects
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    deep_clone = function(name, value) {
      if (name %in% c('children')) {
        lapply(value, function(x) {if (inherits(x, "R6")) x$clone(deep = TRUE) else x})
      } else {
        value
      }
    }
  )

)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Retrieve character representation of ZdogAnchor
#'
#' @param x ZdogAnchor object
#' @param ... other arguments
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
as.character.ZdogAnchor <- function(x, ...) {
  x$as_character(...)
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @rdname ZdogAnchor
#' @usage NULL
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
zdog_anchor <- function(...) {
  ZdogAnchor$new(...)
}




if (FALSE) {
  rect1 <- ztag$rect(width = 64, height = 64, stroke = 16, color = '#ea0')$
    translate(x = -40)

  rect2 <- rect1$copy()$
    translate(x = 48)$
    update(color = '#c25')

  zdog <- zdog_ill(rect1, rect2)
  zdog
  rect1
}


if (FALSE) {
  rect1 <- ztag$rect(width = 64, height = 64, stroke = 16, color = '#ea0')$
    translate(x = -40)

  ss <- rect1$shape(x = 0, y=0, color = '#00f', stroke = 10)
  ss

  rect2 <- rect1$copyGraph()$
    translate(x = 48)$
    update(color = '#c25')

  zdog <- zdog_ill(rect1, rect2)
  zdog
  rect1

  zdog$show()
}




















