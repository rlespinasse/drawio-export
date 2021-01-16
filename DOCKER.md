# Draw.io Export

Export Draw.io diagrams using command line / docker

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
  ./file1.drawio -> ./export/file1-Page-1.pdf
  ++ export page 2 : Page 2
  +++ generate pdf file
  ./file1.drawio -> ./export/file1-Page-2.pdf
  ```

Want to read more, go to [rlespinasse/drawio-export][1] on GitHub.

[1]: https://github.com/rlespinasse/drawio-export
[2]: https://github.com/rlespinasse/drawio-export/blob/master/Dockerfile
