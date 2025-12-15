module.exports = {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        // Original HyFX colors (kept for compatibility)
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
        // OrbisFX website colors (from orbisfx.co)
        orbisfx: {
          dark: "#0e0e10",
          darker: "#0a0a0c",
          card: "#141417",
          border: "#2d2d30",
          text: "#eeeae3",
          gold: "#fcd34d",
          "gold-dark": "#d97706",
          cyan: "#0092cc",
          "cyan-light": "#00b0f4",
          "cyan-dark": "#0080b0",
          "cyan-border": "#005070",
          "cyan-shadow": "#003650",
        },
      },
      fontFamily: {
        // Cinzel - Used on orbisfx.co website for headings
        hytale: ["Cinzel", "serif"],
        // Lexend - Alternative heading font (original launcher)
        lexend: ["Lexend", "sans-serif"],
        // JetBrains Mono - Code/monospace
        mono: ["JetBrains Mono", "monospace"],
        // Open Sans / Nunito Sans - Body text
        body: ["Nunito Sans", "Open Sans", "sans-serif"],
      },
    },
  },
  plugins: [],
}
