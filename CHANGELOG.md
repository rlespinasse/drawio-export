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
