# Draw.io Export

Export Draw.io diagrams using command line / docker

## Installation

```bash
docker pull rlespinasse/drawio-export
```

See [Dockerfile][2]

## Usage

```bash
$ cd directory-with-drawio-files
$ docker run -it --privileged -v $(pwd):/data rlespinasse/drawio-export
prepare './export' folder
cleanup './export/file-*' content
export page 1 > ./file1.drawio -> ./export/file1-Page-1.pdf
export page 2 > ./file1.drawio -> ./export/file1-Page-2.pdf
```

Want to read more, go to [rlespinasse/drawio-export][1] on GitHub.

[1]: https://github.com/rlespinasse/drawio-export
[2]: https://github.com/rlespinasse/drawio-export/blob/master/Dockerfile
