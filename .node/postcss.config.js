module.exports = {
  plugins: [
    require('postcss-preset-env')({
      stage: 0,
      features: {
        'matches-pseudo-class': false,
      },
    }),
  ],
};
