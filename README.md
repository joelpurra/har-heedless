# [har-heedless](https://github.com/joelpurra/har-heedless/)

Scriptable batch downloading of webpages to generate [HTTP Archive (HAR) files](http://www.softwareishard.com/blog/har-12-spec/), using [PhantomJS](http://phantomjs.org/). See [har-dulcify](https://github.com/joelpurra/har-dulcify/) for aggregate HAR analysis. You might want to use [har-portent](https://github.com/joelpurra/har-portent/), which runs both downloads multiple dataset variations using har-heedless and then analyzes them with har-dulcify in a single step.


- Downloads the front web page of all domains in a dataset.
  - Input is a text file with one domain name per line.
  - Downloads `n` domains in parallel.
    - Tested with over 100 parallel requests on a single of moderate speed and memory. YMMV.
    - Machine load heavily depends on the complexity and response rate of the average domain in the dataset.
  - Shows progress as well as expected time to finish downloads.
  - Download domains with different prefixes as separate dataset variations.
    - Default prefixes:
      - `http://`
      - `https://`
      - `http://www.`
      - `https://www.`
  - Retries failed domains twice to reduce effect of any intermittent problems.
    - Increases domain timeouts for failed domains.
  - Saves screenshots of all webpages.



## Usage

```bash
# Downloads domain front pages in parallel.
# domains | ./src/domain/parallel.sh <prefix> <parallelism> --screenshot <true|false>
<domains.txt ./src/domain/parallel.sh 'https://www.' 10 --screenshot true

# More advanced usage, with pipe-viewer (pv) for speed estimates.
size=$(wc -l domains.txt | awk '{ print $1 }')
pv --line-mode --size "$size" -cN "input" domains.txt | ./src/domain/parallel.sh 'https://www.' 10 --screenshot true | pv --line-mode --size "$size" -cN "output" >> "domains.log"
```

Other options:

```bash
# Download domain front pages in serial. This can be very slow.
# domains | ./src/domain/serial.sh <prefix> --screenshot <true|false>
<domains.txt ./src/domain/serial.sh 'https://www.' --screenshot true

# Download custom URLs in parallel. Note that almost no testing of non-front-page donwloading has been done.
# urls | ./src/url/parallel.sh --screenshot <true|false>
<urls.txt ./src/url/parallel.sh --screenshot true

# Download custom URLs in serial. This can be very slow. Note that almost no testing of non-front-page donwloading has been done.
# urls | ./src/url/serial.sh --screenshot <true|false>
<urls.txt ./src/url/serial.sh --screenshot true

# Download a single URL. Note that almost no testing of non-front-page donwloading has been done.
# ./src/url/single.sh <URL> --screenshot <true|false>
./src/url/single.sh 'http://joelpurra.com/' --screenshot true

# Download fetch a single HAR, optionally with an embedded screenshot. Note that almost no testing of non-front-page donwloading has been done.
# ./src/get/har.sh <URL> --screenshot <true|false>
./src/get/har.sh 'http://joelpurra.com/' --screenshot true
```


## Original purpose

Built as a component in [Joel Purra's master's thesis](http://joelpurra.com/projects/masters-thesis/) research, where downloading lots of front pages in the .se top level domain zone was required to analyze their content and use of internal/external resources.



## Thanks

- `netsniff.js` is based on the [example with the same name](https://github.com/ariya/phantomjs/blob/master/examples/netsniff.js) in [PhantomJS](http://phantomjs.org/), created by Ariya Hidayat, release under the [BSD 3-Clause "New" or "Revised" License (BSD-3-Clause)](http://opensource.org/licenses/BSD-3-Clause).
- [`URLUtils.js`](https://gist.github.com/Yaffle/1088850) by [Yaffle](https://github.com/Yaffle). Released into the public domain.

---

Copyright (c) 2014, 2015 [Joel Purra](http://joelpurra.com/). Released under [GNU General Public License version 3.0 (GPL-3.0)](https://www.gnu.org/licenses/gpl.html).
