# Draw.io Export

Export Draw.io diagrams using docker

## Features

* Recursive export
* Partial export (newer, or based on git reference)
* Additional export formats with link extraction

## Supported Export formats

* **draw.io** export formats : jpg, pdf, png, svg, vsdx, and xml
* **drawio-exporter** additional formats
  * adoc - Export in PNG and create an additional Asciidoc file (with support external links).
  * md - Export in PNG and create an additional Markdown file (with support external links).

## Installation

```bash
docker pull rlespinasse/drawio-export
```

See [Dockerfile][2]

## Usage

Print the available options

  ```bash
  docker run -it rlespinasse/drawio-export --help
  ```

Simple run with default options

  ```bash
  $ cd directory-with-drawio-files
  $ docker run -it -v $(pwd):/data rlespinasse/drawio-export
  + export file : ./file1.drawio
  ++ export page 1 : Page-1
  +++ generate pdf file
  ++ export page 2 : Page 2
  +++ generate pdf file
  ```

Want to read more, go to [rlespinasse/drawio-export][1] on GitHub.

[1]: https://github.com/rlespinasse/drawio-export
[2]: https://github.com/rlespinasse/drawio-export/blob/master/Dockerfile
