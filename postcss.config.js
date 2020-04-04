module.exports = {
  plugins: [
    require('autoprefixer'),
    require('postcss-preset-env')({
      stage: 0,
      features: {
        'matches-pseudo-class': false,
      },
    }),
  ],
};
