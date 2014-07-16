if (!Date.prototype.toISOString) {
    Date.prototype.toISOString = function() {
        function pad(n) {
            return n < 10 ? '0' + n : n;
        }

        function ms(n) {
            return n < 10 ? '00' + n : n < 100 ? '0' + n : n
        }
        return this.getFullYear() + '-' +
            pad(this.getMonth() + 1) + '-' +
            pad(this.getDate()) + 'T' +
            pad(this.getHours()) + ':' +
            pad(this.getMinutes()) + ':' +
            pad(this.getSeconds()) + '.' +
            ms(this.getMilliseconds()) + 'Z';
    }
}

function isRedirect(reply) {
    return [301, 302].indexOf(reply.status) >= 0;
}

function getHeaderValue(reply, name) {
    var nameLowerCase = name.toLowerCase(),
        value = reply.headers.reduce(function(prev, header) {
            if (header.name.toLowerCase() === nameLowerCase) {
                return header.value;
            }

            return prev;
        }, null);

    return value;
}

function createHAR(address, title, startTime, resources, msg) {
    var entries = [];

    resources.forEach(function(resource) {
        var request = resource.request,
            startReply = resource.startReply,
            endReply = resource.endReply;

        // if (!request || !startReply || !endReply) {
        //     return;
        // }

        startReply = startReply || {};
        startReply.bodySize = startReply.bodySize || -1;

        endReply = endReply || {};
        endReply.bodySize = endReply.bodySize || -1;

        // Exclude Data URI from HAR file because
        // they aren't included in specification
        if (request.url.match(/^data:[a-z;,]/i)) {
            return;
        }

        entries.push({
            startedDateTime: request.time.toISOString(),
            time: endReply.time - request.time,
            request: {
                method: request.method,
                url: request.url,
                httpVersion: "HTTP/1.1",
                cookies: [],
                headers: request.headers,
                queryString: [],
                headersSize: -1,
                bodySize: -1,
                comment: request.comment
            },
            response: {
                status: endReply.status,
                statusText: endReply.statusText,
                httpVersion: null,
                cookies: [],
                headers: endReply.headers,
                redirectURL: (isRedirect(endReply) && getHeaderValue(endReply, "Location")) || "",
                headersSize: -1,
                bodySize: startReply.bodySize,
                content: {
                    size: startReply.bodySize,
                    mimeType: endReply.contentType
                },
                comment: [startReply.comment, endReply.comment].join("\n").trim()
            },
            cache: {},
            timings: {
                blocked: 0,
                dns: -1,
                connect: -1,
                send: 0,
                wait: startReply.time - request.time,
                receive: endReply.time - startReply.time,
                ssl: -1
            },
            pageref: address
        });
    });

    return {
        log: {
            version: '1.2',
            creator: {
                name: "PhantomJS",
                version: phantom.version.major + '.' + phantom.version.minor + '.' + phantom.version.patch
            },
            pages: [{
                startedDateTime: startTime.toISOString(),
                id: address,
                title: title,
                pageTimings: {
                    onLoad: page.endTime - page.startTime
                }
            }],
            entries: entries,
            comment: msg
        }
    };
}

function exitWithErrorMessage(msg) {
    function asyncExit() {
        console.log("FAIL: " + msg);

        if (page) {
            try {
                page.close();
            } catch (e) {
                console.log("FAIL: Could not close the page; " + e);
            }
        }

        phantom.exit(1);
    }

    var timerId = setTimeout(asyncExit, 100);
}

function exitAfterTimeout(timeout) {
    function loadTimeout() {
        return exitWithErrorMessage('Could not completely load the address; timeout after ' + timeout + ' milliseconds.');
    }

    var timerId = setTimeout(loadTimeout, timeout);
}

function buildErrorResponse(errorObject) {
    var response = {
        // http://www.softwareishard.com/blog/har-12-spec/#response
        // http://phantomjs.org/api/webpage/handler/on-resource-received.html
        "status": errorObject.status || errorObject.errorCode || -1,
        "statusText": errorObject.statusText || errorObject.errorString || null,
        "httpVersion": errorObject.httpVersion || null,
        "cookies": errorObject.cookies || [],
        "headers": errorObject.headers || [],
        "content": errorObject.content || {},
        "redirectURL": errorObject.redirectURL || "",
        "headersSize": errorObject.headersSize || -1,
        "bodySize": errorObject.bodySize || -1,
        "comment": errorObject.comment || "",

        // http://phantomjs.org/api/webpage/handler/on-resource-timeout.html
        // http://phantomjs.org/api/webpage/handler/on-resource-error.html
        "id": errorObject.id,
        "method": errorObject.method,
        "url": errorObject.url,
        "time": errorObject.time,
        "errorCode": errorObject.errorCode,
        "errorString": errorObject.errorString
    };

    return response;
}

var page = require('webpage').create(),
    system = require('system'),
    DEFAULT_PAGE_TIMEOUT = 60 * 1000,
    DEFAULT_RESOURCE_TIMEOUT = 30 * 1000,
    DEFAULT_SLEEP_AFTER_OPEN = 10 * 1000,
    errorMessages = [];

if (system.args.length === 1) {
    console.log('Usage: netsniff.js <some URL>');
    phantom.exit(1);
} else {
    // Viewport size isn't the same as screen resolution, but this is a good screenshot size.
    // https://webmasters.stackexchange.com/questions/10436/browser-window-size-statistics
    // http://gs.statcounter.com/
    // http://www.w3counter.com/globalstats.php
    page.viewportSize = {
        width: 1024,
        height: 768
    };

    page.address = system.args[1];
    page.resources = [];
    page.settings.resourceTimeout = DEFAULT_RESOURCE_TIMEOUT;

    page.onLoadStarted = function() {
        page.startTime = new Date();
    };

    page.onResourceRequested = function(req) {
        page.resources[req.id] = {
            request: req,
            startReply: null,
            endReply: null
        };
    };

    page.onError = function(msg, trace) {
        // Used to catch Javascript errors on the loaded page
        errorMessages.push("JavaScript: An error occured; " + msg);
    };

    page.onResourceError = function(req) {
        var originalRequest = page.resources[req.id],
            msg = 'Could not load the resource; ' + req.errorCode + " \"" + req.errorString + "\" " + req.url,
            response = buildErrorResponse(req);

        response.comment = ((!!response.comment) ? response.comment + "\n" + msg : msg);
        originalRequest.endReply = response;
    };

    page.onResourceTimeout = function(req) {
        var originalRequest = page.resources[req.id],
            msg = 'Could not load the resource; timeout after ' + page.settings.resourceTimeout + ' milliseconds ' + req.errorCode + " \"" + req.errorString + "\" " + req.url,
            response = buildErrorResponse(req);

        response.comment = ((!!response.comment) ? response.comment + "\n" + msg : msg);
        originalRequest.startReply = response;
    };

    page.onResourceReceived = function(res) {
        if (res.stage === 'start') {
            page.resources[res.id].startReply = res;
        }
        if (res.stage === 'end') {
            page.resources[res.id].endReply = res;
        }
    };

    function afterSleepingAfterOpen(status) {
        var har,
            msg;

        if (status !== 'success') {
            errorMessages.push('Page: opening the URL was not successful: ' + status + '; ' + page.address);
        }

        page.endTime = new Date();
        page.title = page.evaluate(function() {
            return document.title;
        });

        msg = errorMessages ? errorMessages.join("\n") : undefined;

        har = createHAR(page.address, page.title, page.startTime, page.resources, msg);

        // NOTE: Screenshots aren't a part of HAR 1.2
        if (system.args[2] == "--screenshot" && system.args[3] == "true") {
            var base64Screenshot = page.renderBase64('PNG');

            har.screenshot = base64Screenshot;
        }

        console.log(JSON.stringify(har, undefined, 4));

        phantom.exit();
    }

    page.open(page.address, function(status) {
        setTimeout(function() {
            afterSleepingAfterOpen(status);
        }, DEFAULT_SLEEP_AFTER_OPEN);
    });

    exitAfterTimeout(DEFAULT_PAGE_TIMEOUT);
}