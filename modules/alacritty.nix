# Module: alacritty terminal emulator
{
  homeModule = {pkgs, ...}: {
    home.packages = [pkgs.alacritty.terminfo];

    programs.alacritty.settings = {
      font.normal.family = "SauceCodePro Nerd Font Mono";
      font.size = 12;

      colors = {
        draw_bold_text_with_bright_colors = true;

        primary.background = "#0d0c0c";
        primary.foreground = "#fff5ed";

        cursor.cursor = "#00ccff";

        normal.black = "#0a0a0a";
        normal.red = "#e61f00";
        normal.green = "#6dd200";
        normal.yellow = "#fa6800";
        normal.blue = "#255ae4";
        normal.magenta = "#ff0084";
        normal.cyan = "#36fcd3";
        normal.white = "#b6afab";

        bright.black = "#73645d";
        bright.red = "#ff3f3d";
        bright.green = "#c1ff05";
        bright.yellow = "#ffa726";
        bright.blue = "#00ccff";
        bright.magenta = "#ff65a0";
        bright.cyan = "#96ffe3";
        bright.white = "#fff5ed";
      };
    };
  };
}
