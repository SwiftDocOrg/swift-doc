#!/bin/sh

set -eux

swift test -c release --enable-test-discovery
./.build/release/swift-doc generate --module-name SwiftDoc --format html Sources
grep ':root' ./.build/documentation/all.css || exit 1
