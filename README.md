
<!-- README.md is generated from README.Rmd. Please edit that file -->

# minizdog <img src="man/figures/logo.png" align="right" height=230/>

<!-- badges: start -->

![](http://img.shields.io/badge/cool-useless-green.svg)
![](http://img.shields.io/badge/mini-verse-blue.svg) [![Travis build
status](https://travis-ci.org/coolbutuseless/minizdog.svg?branch=master)](https://travis-ci.org/coolbutuseless/minizdog)
<!-- badges: end -->

`minizdog` is a package for building [Zdog](https://zzz.dog)
illustrations in R.

This package was inspired by [OganM](https://twitter.com/OganM)’s
package called [rdog](https://github.com/oganm/rdog). That package is
much more feature complete, with better documentation and examples and
other stuff.

This package is part of an ongoing exploration of writing document
interfaces with R and [R6](https://cran.r-project.org/package=R6) -
every drawing feature is mapped to an R6 object, and these objects are
nested within each other to create the document.

## Installation

You can install the development version from
[GitHub](https://github.com/coolbutuseless/minizdog) with:

``` r
# install.packages("devtools")
devtools::install_github("coolbutuseless/minizdog")
```

## All-in-one example

``` r
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Initialize a document
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
zdog <- ZdogIllustration$new(zoom = 2, yincrement = 0.03)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create a circle as a separate object
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ell <- minizdog::ZdogEllipse$new(diameter = 20, stroke = 5, color = '#636')$
  translate(z = -20)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create a rectangle directly as a child of the illustration
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
zdog$rect(width = 20, height = 20, stroke = 3)$
  update(fill = TRUE, color = '#e62')$
  translate(z = -10)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create a polygon using the `ztag` helper
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
poly <- ztag$polygon(radius = 40, sides = 6)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# create some text
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
text <- ZdogText$new(value = "#RStats\\n\\nmini\\nzdog")$
  update(color = '#00f', textAlign = 'center', fontSize = 20)$
  translate(y = 15)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Append the standalone elements to the main document
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
zdog$append(ell)
zdog$append(poly)
zdog$append(text)
```

``` r
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# If running in Rstudio this will open the zdog illustration in the viewer pane.
# Github limits what a README can show, so this is just a GIF animation of
# what the above javascript creates
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
zdog$show()
```

<img src = "man/figures/badlogo-o.gif">

``` r
as.character(zdog) # will print just the javascript code
zdog$as_html()     # wraps the javascript in some html boilerplate
```

<details close>

<summary> <span title="as.character(zdog) output (JS)">
as.character(zdog) output (JS)</span> </summary>

    let isSpinning = true;
    Zfont.init(Zdog);
    var default_font = new Zdog.Font({
      src: 'https://cdn.jsdelivr.net/gh/jaames/zfont/demo/fredokaone.ttf'
    });
          
    let Ill01 = new Zdog.Illustration({
      element: '.zdog-canvas',
      zoom: 2,
      centered: true,
      dragRotate: true,
      onDragStart: function() {isSpinning = false;}
    });
      let Rect01 = new Zdog.Rect({
        stroke: 3,
        width: 20,
        height: 20,
        addTo: Ill01,
        fill: true,
        color: '#e62',
        translate: { z: -10 }
      });
      let Ellipse01 = new Zdog.Ellipse({
        stroke: 5,
        color: '#636',
        diameter: 20,
        translate: { z: -20 },
        addTo: Ill01
      });
      let Polygon01 = new Zdog.Polygon({
        radius: 40,
        sides: 6,
        addTo: Ill01
      });
      let Text01 = new Zdog.Text({
        value: '#RStats\n\nmini\nzdog',
        fontSize: 20,
        textAlign: 'center',
        textBaseline: 'left',
        font: default_font,
        color: '#00f',
        translate: { y: 15 },
        addTo: Ill01
      });
    function animate() {
      // rotate illo each frame
      if (isSpinning) {
        Ill01.rotate.x += 0;
        Ill01.rotate.y += 0.03;
        Ill01.rotate.z += 0;
      }
      Ill01.updateRenderGraph();
      // animate next frame
      requestAnimationFrame( animate );
    }
    // start animation
    animate();

</details>

<br />

<details open>

<summary> <span title="zdog$as_html() output"> zdog$as.html() output
</span> </summary>

    <!doctype html>
    <html lang='en'>
    <head>
    <meta charset='UTF-8'>
    </head>
    <body>
    <canvas id='canvas' class='zdog-canvas' width = '300', height = '300'>
    Your viewer doesn't support HTML5 canvas
    </canvas>
    
    <script src='https://unpkg.com/zdog@1/dist/zdog.dist.min.js'></script>
    <script src='https://cdn.jsdelivr.net/npm/zfont/dist/zfont.min.js'></script>
    <script>
    let isSpinning = true;
    Zfont.init(Zdog);
    var default_font = new Zdog.Font({
      src: 'https://cdn.jsdelivr.net/gh/jaames/zfont/demo/fredokaone.ttf'
    });
          
    let Ill01 = new Zdog.Illustration({
      element: '.zdog-canvas',
      zoom: 2,
      centered: true,
      dragRotate: true,
      onDragStart: function() {isSpinning = false;}
    });
      let Rect01 = new Zdog.Rect({
        stroke: 3,
        width: 20,
        height: 20,
        addTo: Ill01,
        fill: true,
        color: '#e62',
        translate: { z: -10 }
      });
      let Ellipse01 = new Zdog.Ellipse({
        stroke: 5,
        color: '#636',
        diameter: 20,
        translate: { z: -20 },
        addTo: Ill01
      });
      let Polygon01 = new Zdog.Polygon({
        radius: 40,
        sides: 6,
        addTo: Ill01
      });
      let Text01 = new Zdog.Text({
        value: '#RStats\n\nmini\nzdog',
        fontSize: 20,
        textAlign: 'center',
        textBaseline: 'left',
        font: default_font,
        color: '#00f',
        translate: { y: 15 },
        addTo: Ill01
      });
    function animate() {
      // rotate illo each frame
      if (isSpinning) {
        Ill01.rotate.x += 0;
        Ill01.rotate.y += 0.03;
        Ill01.rotate.z += 0;
      }
      Ill01.updateRenderGraph();
      // animate next frame
      requestAnimationFrame( animate );
    }
    // start animation
    animate();
    </script>
    
    </body>
    </html>

</details>

<br />
