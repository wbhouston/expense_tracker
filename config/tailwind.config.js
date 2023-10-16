const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/form_objects/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/lib/**/*.rb",
    "./app/views/**/*.{erb,haml,html,slim}",
    "./app/view_objects/**/*.rb",
    './config/initializers/simple_form.rb',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
  ],
};
