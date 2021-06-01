const fs = require("fs");
const path = require('path');
const postcss = require("postcss");

const source = "../Assets/css/all.css";
const destination = "../Sources/swift-doc/Generated/CSS.swift";

const input = fs.readFileSync(source);

postcss([
  require("postcss-preset-env")({
    stage: 0,
    features: {
      "matches-pseudo-class": false,
    },
  }),
  require("cssnano")({
    preset: "default",
  }),
])
  .process(input, { from: source, to: destination })
  .then((result) => {
    const output = [
      `// This file was automatically generated and should not be edited.`,
      `let css: String = #"${result.css}"#`,
    ].join("\n\n") + "\n";

    fs.mkdir(path.dirname(destination), () => {
      fs.writeFileSync(destination, output);
    });
  });
