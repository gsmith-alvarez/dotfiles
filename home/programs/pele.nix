{ pkgs, ... }:
let
  sources = pkgs.callPackage ../../_sources/generated.nix { };
  peleCli = pkgs.writeText "pele-mmdc.js" ''
    import { render } from "./pele.js";
    import { readFileSync, writeFileSync, mkdtempSync, rmSync } from "fs";
    import { tmpdir } from "os";
    import { join } from "path";
    import { spawnSync } from "child_process";

    const args = process.argv.slice(2);
    let input = "-";
    let output = "-";
    let theme = "dark";
    let bg = "transparent";
    let scale = 1;

    for (let i = 0; i < args.length; i++) {
      const a = args[i];
      if ((a === "-i" || a === "--input") && args[i + 1]) input = args[++i];
      else if ((a === "-o" || a === "--output") && args[i + 1]) output = args[++i];
      else if ((a === "-t" || a === "--theme") && args[i + 1]) theme = args[++i];
      else if ((a === "-b" || a === "--backgroundColor") && args[i + 1]) bg = args[++i];
      else if ((a === "-s" || a === "--scale") && args[i + 1]) scale = parseFloat(args[++i]) || 1;
    }

    const src = readFileSync(input === "-" ? 0 : input, "utf8");
    let { svg } = render(src, {
      fontFamily: "JetBrains Mono, sans-serif",
      monospaceFontFamily: "JetBrains Mono, monospace",
    });

    const isLight = theme === "light" || theme === "neutral";
    const palette = isLight
      ? {
          "--_bg": "#eff1f5",
          "--_fg": "#4c4f69",
          "--_m": "#6c6f85",
          "--_l": "#5c5f77",
          "--_s": "#e6e9ef",
          "--_a": "#dce0e8",
          "--_b": "#9ca0b0",
          "--_c": "#8839ef",
          "--_r": "4px",
          "--_fm": "JetBrains Mono, monospace",
          "--_tw": "bold",
          "--_hw": "bold",
          "--_w": "bold",
          "--pele-bg": "#eff1f5",
          "--pele-fg": "#4c4f69",
          "--pele-fg-on-light": "#4c4f69",
          "--pele-fg-on-dark": "#eff1f5",
          "--pele-muted": "#6c6f85",
          "--pele-line": "#5c5f77",
          "--pele-surface": "#e6e9ef",
          "--pele-surface-alt": "#dce0e8",
          "--pele-border": "#9ca0b0",
          "--pele-accent": "#8839ef",
          "--pele-critical": "#d20f39",
          "--pele-error": "#d20f39",
          "--pele-radius": "4px",
          "--pele-font": "JetBrains Mono, sans-serif",
          "--pele-font-mono": "JetBrains Mono, monospace",
          "--pele-series-1": "#1e66f5",
          "--pele-series-2": "#fe640b",
          "--pele-series-3": "#40a02b",
          "--pele-series-4": "#d20f39",
          "--pele-series-5": "#179299",
          "--pele-series-6": "#df8e1d",
          "--pele-series-7": "#8839ef",
          "--pele-series-8": "#ea76cb",
        }
      : {
          "--_bg": "#1e1e2e",
          "--_fg": "#cdd6f4",
          "--_m": "#a6adc8",
          "--_l": "#bac2de",
          "--_s": "#313244",
          "--_a": "#181825",
          "--_b": "#585b70",
          "--_c": "#cba6f7",
          "--_r": "4px",
          "--_fm": "JetBrains Mono, monospace",
          "--_tw": "bold",
          "--_hw": "bold",
          "--_w": "bold",
          "--pele-bg": "#1e1e2e",
          "--pele-fg": "#cdd6f4",
          "--pele-fg-on-light": "#1e1e2e",
          "--pele-fg-on-dark": "#cdd6f4",
          "--pele-muted": "#a6adc8",
          "--pele-line": "#bac2de",
          "--pele-surface": "#313244",
          "--pele-surface-alt": "#181825",
          "--pele-border": "#585b70",
          "--pele-accent": "#cba6f7",
          "--pele-critical": "#f38ba8",
          "--pele-error": "#f38ba8",
          "--pele-radius": "4px",
          "--pele-font": "JetBrains Mono, sans-serif",
          "--pele-font-mono": "JetBrains Mono, monospace",
          "--pele-series-1": "#89b4fa",
          "--pele-series-2": "#fab387",
          "--pele-series-3": "#a6e3a1",
          "--pele-series-4": "#f38ba8",
          "--pele-series-5": "#94e2d5",
          "--pele-series-6": "#f9e2af",
          "--pele-series-7": "#cba6f7",
          "--pele-series-8": "#f5c2e7",
        };

    svg = svg.replace(/style="rx:var\(--_r\)"/g, 'rx="4" ry="4"');
    svg = svg.replace(/var\((--[a-zA-Z0-9_-]+)(?:,[^)]*)?\)/g, (m, k) => palette[k] || m);

    if (output === "-" || output.endsWith(".svg")) {
      writeFileSync(output === "-" ? 1 : output, svg);
      process.exit(0);
    }

    const dir = mkdtempSync(join(tmpdir(), "pele-"));
    const svgPath = join(dir, "diagram.svg");
    try {
      writeFileSync(svgPath, svg);
      const zoom = String(Math.max(1, scale * 2));
      const resvgArgs = [
        "--zoom",
        zoom,
        "--font-family",
        "JetBrains Mono",
        "--monospace-family",
        "JetBrains Mono",
      ];
      if (bg && bg !== "transparent") {
        resvgArgs.push("--background", bg === "default" ? palette["--_bg"] : bg);
      }
      resvgArgs.push(svgPath, output);
      const res = spawnSync("@resvg@", resvgArgs, { stdio: "inherit" });
      process.exit(res.status ?? 1);
    } finally {
      rmSync(dir, { recursive: true, force: true });
    }
  '';
  pele-mmdc = pkgs.stdenvNoCC.mkDerivation {
    pname = "pele-mmdc";
    inherit (sources.pele) version src;
    sourceRoot = "package";
    installPhase = ''
      runHook preInstall
      install -Dm644 dist/pele.js $out/share/pele/pele.js
      substitute ${peleCli} $out/share/pele/cli.js \
        --replace-fail "@resvg@" "${pkgs.resvg}/bin/resvg"
      mkdir -p $out/bin
      cat <<EOF > $out/bin/mmdc
      #!${pkgs.runtimeShell}
      exec ${pkgs.bun}/bin/bun $out/share/pele/cli.js "\$@"
      EOF
      chmod +x $out/bin/mmdc
      ln -s $out/bin/mmdc $out/bin/pele
      runHook postInstall
    '';
  };
in
{
  home.packages = [ pele-mmdc ];
}
