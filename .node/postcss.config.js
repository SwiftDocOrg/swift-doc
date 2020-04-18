module.exports = {
  plugins: [
    require("postcss-nested"),
    require("postcss-preset-env")({
      stage: 0,
      features: {
        "matches-pseudo-class": false,
      },
    }),
    require("cssnano")({
      preset: "default",
    }),
  ],
};
