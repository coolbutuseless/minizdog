
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' HTML5 Zdog Builder
#'
#' @import R6
#' @import glue
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ZdogIllustration <- R6::R6Class(
  "ZdogIllustration", inherit = ZdogAnchor,

  public = list(
    width      = NULL,
    height     = NULL,
    xincrement = NULL,
    yincrement = NULL,
    zincrement = NULL,
    font_name  = NULL,
    font_src   = NULL,

    initialize = function(..., width = 300, height = 300,
                          element    = '.zdog-canvas',
                          zoom       = NULL,
                          centered   = TRUE,
                          dragRotate = TRUE,
                          resize     = NULL,
                          yincrement = 0.01,
                          xincrement = 0,
                          zincrement = 0
                          ) {


      self$width      <- width
      self$height     <- height
      self$xincrement <- xincrement
      self$yincrement <- yincrement
      self$zincrement <- zincrement
      self$font_name  <- list()
      self$font_src   <- list()

      super$initialize(
        ...,
        type       ='Illustration',
        element    = element,
        zoom       = zoom,
        centered   = centered,
        dragRotate = dragRotate,
        resize     = resize,
        onDragStart = "function() {isSpinning = false;}"
      )

      self
    },


    add_font = function(font_name, font_src) {
      self$font_name <- c(self$font_name, font_name)
      self$font_src  <- c(self$font_src , font_src )
      invisible(self)
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Character representatino of just the javascript for this zdog document
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    as_character = function(...) {
      open <- "let isSpinning = true;
Zfont.init(Zdog);
var default_font = new Zdog.Font({
  src: 'https://cdn.jsdelivr.net/gh/jaames/zfont/demo/fredokaone.ttf'
});
      "

      fonts <- glue("var {self$font_name} = new Zdog.Font({{ src: '{self$font_src}' }});")

      res <- super$as_character(...)

      close <- glue("
// update & render
{self$id}.updateRenderGraph();
")

      close <- glue("
function animate() {{
  // rotate illo each frame
  if (isSpinning) {{
    {self$id}.rotate.x += {self$xincrement};
    {self$id}.rotate.y += {self$yincrement};
    {self$id}.rotate.z += {self$zincrement};
  }}
  {self$id}.updateRenderGraph();
  // animate next frame
  requestAnimationFrame( animate );
}}
// start animation
animate();")


      paste(c(open, fonts, res, close), collapse = "\n")
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Character representation of the full HTML + Javascript to render this
    # ZdogIllustration
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    as_html = function(...) {
      html_string <- glue("<!doctype html>
<html lang='en'>
<head>
<meta charset='UTF-8'>
</head>
<body>
<canvas id='canvas' class='zdog-canvas' width = '{self$width}', height = '{self$height}'>
Your viewer doesn't support HTML5 canvas
</canvas>

<script src='https://unpkg.com/zdog@1/dist/zdog.dist.min.js'></script>
<script src='https://cdn.jsdelivr.net/npm/zfont/dist/zfont.min.js'></script>
<script>
{self$as_character()}
</script>

</body>
</html>")
      html_string
    },

    zoom = function(zoom) {
      self$attribs$zoom <- zoom
      invisible(self)
    },

    centered = function(centered) {
      self$attribs$centered <- centered
      invisible(self)
    },

    dragRotate = function(dragRotate) {
      self$attribs$dragRotate <- dragRotate
      invisible(self)
    },

    resize = function(resize) {
      self$attribs$resize <- resize
      invisible(self)
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Output zdog document to screen
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    print = function(...) {
      cat(self$as_character())
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Save HTML + JS to fully render this ZdogIllustration
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    save_html = function(filename) {
      writeLines(self$as_html(), filename)
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # View HTML in whatever viewer is available
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    show = function(viewer = getOption("viewer", utils::browseURL)) {
      www_dir <- tempfile("viewhtml")
      dir.create(www_dir)
      index_html <- file.path(www_dir, "index.html")
      self$save_html(index_html)

      if (!is.null(viewer)) {
        viewer(index_html)
      } else {
        warning("No viewer available.")
      }
      invisible(index_html)
    }
  )
)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Helper to create ZdogIllustration objects
#'
#' @param width,height Zdog dimensions
#' @param ... Initialise the zdog doc with these elements
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
zdog_ill <- function(..., width = 240, height = 240) {
  ZdogIllustration$new(..., width = width, height = height)
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert a ConvasDocument to a string
#'
#' @param x ZdogIllustration object
#' @param ... other arguments
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
as.character.ZdogIllustration <- function(x, ...) {
  x$as_character(...)
}





if (FALSE) {
  zdog <- zdog_ill(zoom = 2)

  ell <- ZdogEllipse$new(diameter = 20, stroke = 5, color = '#636')$
    translate(z = 10)

  zdog$rect(width = 20, height = 20, stroke = 3)$
    update(fill = TRUE, color = '#e62')$
    translate(z = -10)

  text <- ZdogText$new(value = "Crap", color = '#00f', textAlign = 'center')

  zdog$append(ell)
  # zdog$append(rect)
  zdog$append(text)
  zdog

  zdog$show()

}

