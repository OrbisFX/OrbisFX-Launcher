module.exports = {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        hyfx: {
          dark: "#0a0a0c",
          darker: "#050505",
          bg: "#0e0e10",
          card: "#141417",
          border: "#2d2d30",
          text: "#eeeae3",
          gold: "#fcd34d",
          cyan: "#0092cc",
          "cyan-light": "#00b0f4",
        },
      },
      fontFamily: {
        hytale: ["Cinzel", "serif"],
        mono: ["JetBrains Mono", "monospace"],
        body: ["Open Sans", "sans-serif"],
      },
    },
  },
  plugins: [],
}
