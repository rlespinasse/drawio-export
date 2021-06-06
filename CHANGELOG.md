# [4.1.0](http://github.com/rlespinasse/drawio-export/compare/4.0.0...4.1.0) (2021-06-06)


### Features

* update drawio-desktop-headless 1.2.0 ([a0b19fc](http://github.com/rlespinasse/drawio-export/commit/a0b19fce73304d90b563ca73608e9a8a3d1668d6))

# [4.0.0](http://github.com/rlespinasse/drawio-export/compare/3.5.0...4.0.0) (2021-03-29)


### Features

* use drawio-exporter as backend ([a8215c3](http://github.com/rlespinasse/drawio-export/commit/a8215c36bc9acfa21783c29426392e46362e7888))


### BREAKING CHANGES

* v3.x deprecated parts are no longer supported

# [3.5.0](http://github.com/rlespinasse/drawio-export/compare/3.4.0...3.5.0) (2021-03-20)


### Features

* deprecate fileext, folder, and path options ([9f178d2](http://github.com/rlespinasse/drawio-export/commit/9f178d2d0acf8bfbfe9db6faf8da682f7982a032))
* use rlespinasse/drawio-desktop-headless as base image ([df59757](http://github.com/rlespinasse/drawio-export/commit/df59757466ee8a051fd2a921fd644ffd2fdc8aad))

# [3.4.0](http://github.com/rlespinasse/drawio-export/compare/3.3.2...3.4.0) (2021-01-19)


### Features

* add --git-ref and --path options ([b6f317f](http://github.com/rlespinasse/drawio-export/commit/b6f317f1634df1d9d522572c53b270c08349ccc7))

## [3.3.2](http://github.com/rlespinasse/drawio-export/compare/3.3.1...3.3.2) (2021-01-11)


### Bug Fixes

* manage filename with space ([2f52f5a](http://github.com/rlespinasse/drawio-export/commit/2f52f5af8f277fbe7dd15666d00a7c3a5c652e68))

## [3.3.1](http://github.com/rlespinasse/drawio-export/compare/3.3.0...3.3.1) (2021-01-10)


### Bug Fixes

* support azure shape ([58caaec](http://github.com/rlespinasse/drawio-export/commit/58caaec4e8feddf7138559257109159e8bb74839))

# [3.3.0](http://github.com/rlespinasse/drawio-export/compare/3.2.1...3.3.0) (2020-10-21)


### Features

* add on-changes option ([0b5dde2](http://github.com/rlespinasse/drawio-export/commit/0b5dde2ac83a83418e416813afcde931fdf1abc3))

## [3.2.1](http://github.com/rlespinasse/drawio-export/compare/3.2.0...3.2.1) (2020-10-18)


### Bug Fixes

* avoid masking return values ([c908f19](http://github.com/rlespinasse/drawio-export/commit/c908f1926d76cd762f3f00f2e44bd1ce2727a552))

# [3.2.0](http://github.com/rlespinasse/drawio-export/compare/3.1.0...3.2.0) (2020-10-03)


### Features

* support xml export ([8e2ad22](http://github.com/rlespinasse/drawio-export/commit/8e2ad2274a3a09f0aa137498f7d93acb6d4432ce))

# [3.1.0](http://github.com/rlespinasse/drawio-export/compare/3.0.0...3.1.0) (2020-10-03)


### Features

* support draw.io options directly ([f9ed896](http://github.com/rlespinasse/drawio-export/commit/f9ed896ff72b2a9c3aafc1985555595e175cbdf4))

# [3.0.0](http://github.com/rlespinasse/drawio-export/compare/2.5.0...3.0.0) (2020-10-03)


### Bug Fixes

* move --disable-dev-shm-usage to the end of the command ([78f9d93](http://github.com/rlespinasse/drawio-export/commit/78f9d9325f748f68a39637a1dc554082d84b74c4))


### Features

* bump to drawio-cli 3.0.0 ([0433ee9](http://github.com/rlespinasse/drawio-export/commit/0433ee908d920f90de628df7216ea2a6a807340a))


### BREAKING CHANGES

* Major update of drawio-cli

# [2.5.0](http://github.com/rlespinasse/drawio-export/compare/2.4.1...2.5.0) (2020-06-30)


### Features

* remove page suffix when only one page ([1393511](http://github.com/rlespinasse/drawio-export/commit/1393511711719d05d8a2d287dc4cf290506d821f))

## [2.4.1](http://github.com/rlespinasse/drawio-export/compare/2.4.0...2.4.1) (2020-05-30)


### Bug Fixes

* support file from vscode drawio plugin ([28f719b](http://github.com/rlespinasse/drawio-export/commit/28f719b191f0cd04296ea93db246ea7416d6b332))

# [2.4.0](http://github.com/rlespinasse/drawio-export/compare/2.3.1...2.4.0) (2020-05-11)


### Features

* stop export immediately on kill signals ([78fe758](http://github.com/rlespinasse/drawio-export/commit/78fe7587964a963d86279da9c3bcb76d1e117f0d))

## [2.3.1](http://github.com/rlespinasse/drawio-export/compare/2.3.0...2.3.1) (2020-05-10)


### Bug Fixes

* print help when an argument is unknown ([b5cc2e6](http://github.com/rlespinasse/drawio-export/commit/b5cc2e644567127550753add00666bf6650f6018))

# [2.3.0](http://github.com/rlespinasse/drawio-export/compare/2.2.2...2.3.0) (2020-05-08)


### Bug Fixes

* protect em dash string  in asciidoc ([6442094](http://github.com/rlespinasse/drawio-export/commit/6442094370eaf7570ad4dae13c4a74a8e32ea412))
* remove trailing & in asciidoc links ([1a1670b](http://github.com/rlespinasse/drawio-export/commit/1a1670b895cf1840cd58e79ca6b4a4459639c875))


### Features

* cleanup previously exported content ([c98c4b0](http://github.com/rlespinasse/drawio-export/commit/c98c4b0e986d17cb220434d9d1359f1a08434076))
* improve --help message ([90348db](http://github.com/rlespinasse/drawio-export/commit/90348db936891772289326a0b4d7c3fb4fa0710b))

## [2.2.2](http://github.com/rlespinasse/drawio-export/compare/2.2.1...2.2.2) (2020-05-05)


### Bug Fixes

* export the correct page based on its number ([eecca3a](http://github.com/rlespinasse/drawio-export/commit/eecca3a193d17b7900a77ae7070f84ab6ce7a448))

## [2.2.1](http://github.com/rlespinasse/drawio-export/compare/2.2.0...2.2.1) (2020-05-03)


### Bug Fixes

* use correct path to image in asciidoc page ([28888c1](http://github.com/rlespinasse/drawio-export/commit/28888c1a16042b527c59bd324639171397db84e2))

# [2.2.0](http://github.com/rlespinasse/drawio-export/compare/2.1.0...2.2.0) (2020-05-03)


### Features

* support very large diagram export ([4758b52](http://github.com/rlespinasse/drawio-export/commit/4758b52db581890cae122c5c9901650c69e46273))

# [2.1.0](http://github.com/rlespinasse/drawio-export/compare/2.0.1...2.1.0) (2020-05-03)


### Bug Fixes

* clean link text from draw.io link format ([ce9500e](http://github.com/rlespinasse/drawio-export/commit/ce9500e3161c916c34ec4fb6a902137099ec6794))
* identify links and text links correctly ([392b7be](http://github.com/rlespinasse/drawio-export/commit/392b7be6231f4c509a282a0881503e155d1ca31f))
* output errors without deprecation warnings ([ee2e283](http://github.com/rlespinasse/drawio-export/commit/ee2e283d0621bc01850a4f9eb518ec315b6548e5))


### Features

* extract links from large diagrams ([7a34197](http://github.com/rlespinasse/drawio-export/commit/7a3419760440071ee60c0206d837ca0f5e9f1cca))
* improve export log ([5e8dbc7](http://github.com/rlespinasse/drawio-export/commit/5e8dbc79cf941ad6871d06d4a7cc814cfdb18d0d))

## [2.0.1](http://github.com/rlespinasse/drawio-export/compare/2.0.0...2.0.1) (2020-05-02)


### Bug Fixes

* override the drawio exported asciidoctor file ([2145b57](http://github.com/rlespinasse/drawio-export/commit/2145b57b65d073f875fdf303c32131c74169da8d))

# [2.0.0](http://github.com/rlespinasse/drawio-export/compare/1.1.0...2.0.0) (2020-05-02)


### Features

* remove need of privileged container ([c5c1917](http://github.com/rlespinasse/drawio-export/commit/c5c1917b5e1c03cac2dd1d014b273755fb12dd4f))


### BREAKING CHANGES

* Use Draw.io desktop previous version
and start with --no-sandbox flag

# [1.1.0](http://github.com/rlespinasse/drawio-export/compare/1.0.0...1.1.0) (2020-05-02)


### Features

* use drawio-cli as docker base image ([d1b7445](http://github.com/rlespinasse/drawio-export/commit/d1b7445858e304cdb624cfd4721905b5602e3dec))

# 1.0.0 (2020-05-01)


### Features

* export draw.io diagrams in folder tree ([6b8055b](http://github.com/rlespinasse/drawio-export/commit/6b8055b69e3a6ec09792cfa6c9c1c439d08e0105))
* support asciidoctor output ([dcb26db](http://github.com/rlespinasse/drawio-export/commit/dcb26db1cc2419bc70e4a099359a9ac1cdf648cc))
* use drawio desktop 13.0.1 ([47a60ba](http://github.com/rlespinasse/drawio-export/commit/47a60baaa35c7295016946609571401dd6706d4e))
