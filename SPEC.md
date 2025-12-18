goal: updating my website

this has 3 pieces:

1. making a new static site host, this should be mostly markdown with the ability to embed html, for other projects this should; color extension, one css file, per file jit, wasm embedding
2. extending the content
3. cleaning up my last one

## links

current website: https://github.com/crazymonkyyy/crazymonkyyy.github.io
lib to steal: https://github.com/adamdruppe/arsd

Download these and add to gitignore

### site gen

it needs a local host, a markdown to html function, opinionated file structure pattern, and for backwards compatibility with my old site a new file format `.partialhtml`

it should have two modes of operating "jit hosting"/full site publishing

there should be a core page gen, when a `foo/bar.html` comes in this looks for `foo/bar.md` and `foo/bar.partialhtml` and creates or recreates bar.html, glueing together the meta definitions of the site

The site should have one and only one css file for a "single source of truth/ stylistic information"; add warnings if some simple style information are overused

Create specs for: acceptable site file structures, and this "partial html" 

Embed "```html <class=foo>```" into the website

### testing
try to recreate my website in a separate folder
make 3 demo projects(again separate folders)
unit test the on test markdown to html strings

EDIT 1:

partial html was suppose to be about saving my article https://crazymonkyyy.github.io/writings/gif.html ; add a feature for a `.bodyhtml`, write a spec for it, it is html but without headers and endlines imply <p> its for direct control when markdown isnt enough, my old website did something manually for this

`init` should take a color scheme; use: https://github.com/crazymonkyyy/leet-haker-colors/blob/master/base-16.csv
