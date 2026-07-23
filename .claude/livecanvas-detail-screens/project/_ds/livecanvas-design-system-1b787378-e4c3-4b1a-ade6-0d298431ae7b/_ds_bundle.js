/* @ds-bundle: {"format":4,"namespace":"LiveCanvasDesignSystem_1b7873","components":[{"name":"Button","sourcePath":"components/controls/Button.jsx"},{"name":"FilterChip","sourcePath":"components/controls/FilterChip.jsx"},{"name":"IconButton","sourcePath":"components/controls/IconButton.jsx"},{"name":"EmptyState","sourcePath":"components/feedback/EmptyState.jsx"},{"name":"TabBar","sourcePath":"components/navigation/TabBar.jsx"},{"name":"TopBar","sourcePath":"components/navigation/TopBar.jsx"},{"name":"MetaChip","sourcePath":"components/wallpaper/MetaChip.jsx"},{"name":"PremiumBadge","sourcePath":"components/wallpaper/PremiumBadge.jsx"},{"name":"WallpaperCard","sourcePath":"components/wallpaper/WallpaperCard.jsx"}],"sourceHashes":{"components/controls/Button.jsx":"ad52301306d5","components/controls/FilterChip.jsx":"cde260d28da6","components/controls/IconButton.jsx":"ea614529f016","components/feedback/EmptyState.jsx":"9a30ab85d553","components/navigation/TabBar.jsx":"3338d8521156","components/navigation/TopBar.jsx":"300fda033887","components/wallpaper/MetaChip.jsx":"e49106ab109f","components/wallpaper/PremiumBadge.jsx":"022a5eb70426","components/wallpaper/WallpaperCard.jsx":"0fcc9c1bc8e0","ui_kits/livecanvas_app/Browse.jsx":"6b6fedb83d05","ui_kits/livecanvas_app/Favorites.jsx":"4ec752f20072","ui_kits/livecanvas_app/Paywall.jsx":"5273a0c9b42a","ui_kits/livecanvas_app/Search.jsx":"480900a78399","ui_kits/livecanvas_app/SetWallpaper.jsx":"b294e3051c5b","ui_kits/livecanvas_app/WallpaperDetail.jsx":"926262748d49","ui_kits/livecanvas_app/data.js":"9a5923bd74b0"},"inlinedExternals":[],"unexposedExports":[]} */

(() => {

const __ds_ns = (window.LiveCanvasDesignSystem_1b7873 = window.LiveCanvasDesignSystem_1b7873 || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// components/controls/Button.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * LiveCanvas Button — primary action control.
 * variant: "primary" (iris solid) | "secondary" (raised surface) | "ghost" | "aurora" (brand gradient, for Premium/CTA moments)
 */
function Button({
  children,
  variant = "primary",
  size = "md",
  fullWidth = false,
  icon,
  iconRight,
  disabled = false,
  onClick,
  style,
  ...rest
}) {
  const heights = {
    sm: 40,
    md: 52,
    lg: 56
  };
  const fonts = {
    sm: 14,
    md: 15,
    lg: 16
  };
  const h = heights[size] || 52;
  const base = {
    display: "inline-flex",
    alignItems: "center",
    justifyContent: "center",
    gap: 10,
    height: h,
    padding: size === "sm" ? "0 16px" : "0 24px",
    width: fullWidth ? "100%" : undefined,
    border: "none",
    borderRadius: "var(--r-pill)",
    fontFamily: "var(--font-body)",
    fontSize: fonts[size] || 15,
    fontWeight: 700,
    letterSpacing: "0.01em",
    cursor: disabled ? "not-allowed" : "pointer",
    opacity: disabled ? 0.4 : 1,
    transition: "transform .12s ease, filter .15s ease, background .15s ease",
    WebkitTapHighlightColor: "transparent",
    whiteSpace: "nowrap"
  };
  const variants = {
    primary: {
      background: "var(--accent)",
      color: "var(--on-accent)",
      boxShadow: "0 6px 18px rgba(124,92,255,0.38)"
    },
    aurora: {
      background: "var(--aurora)",
      color: "#fff",
      boxShadow: "0 8px 24px rgba(124,92,255,0.40)"
    },
    secondary: {
      background: "var(--bg-raised)",
      color: "var(--text-primary)",
      border: "1px solid var(--border-subtle)"
    },
    ghost: {
      background: "transparent",
      color: "var(--text-secondary)"
    }
  };
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    onClick: disabled ? undefined : onClick,
    disabled: disabled,
    style: {
      ...base,
      ...variants[variant],
      ...style
    },
    onMouseDown: e => !disabled && (e.currentTarget.style.transform = "scale(0.97)"),
    onMouseUp: e => e.currentTarget.style.transform = "scale(1)",
    onMouseLeave: e => e.currentTarget.style.transform = "scale(1)"
  }, rest), icon && /*#__PURE__*/React.createElement("i", {
    className: `ph ph-${icon}`,
    style: {
      fontSize: "1.25em"
    }
  }), children, iconRight && /*#__PURE__*/React.createElement("i", {
    className: `ph ph-${iconRight}`,
    style: {
      fontSize: "1.25em"
    }
  }));
}
Object.assign(__ds_scope, { Button });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/controls/Button.jsx", error: String((e && e.message) || e) }); }

// components/controls/FilterChip.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * LiveCanvas FilterChip — tag / category filter pill.
 * Inactive = raised surface; active = iris fill. Optional leading icon + trailing count.
 */
function FilterChip({
  label,
  active = false,
  icon,
  count,
  onClick,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    onClick: onClick,
    style: {
      display: "inline-flex",
      alignItems: "center",
      gap: 6,
      height: "var(--chip-h)",
      padding: "0 14px",
      borderRadius: "var(--r-pill)",
      fontFamily: "var(--font-body)",
      fontSize: "var(--fs-sm)",
      fontWeight: 500,
      cursor: "pointer",
      whiteSpace: "nowrap",
      transition: "background .15s ease, color .15s ease, transform .12s ease",
      WebkitTapHighlightColor: "transparent",
      flexShrink: 0,
      background: active ? "var(--accent)" : "var(--bg-raised)",
      color: active ? "var(--on-accent)" : "var(--text-secondary)",
      border: active ? "1px solid transparent" : "1px solid var(--border-subtle)",
      ...style
    },
    onMouseDown: e => e.currentTarget.style.transform = "scale(0.96)",
    onMouseUp: e => e.currentTarget.style.transform = "scale(1)",
    onMouseLeave: e => e.currentTarget.style.transform = "scale(1)"
  }, rest), icon && /*#__PURE__*/React.createElement("i", {
    className: `ph ph-${icon}`,
    style: {
      fontSize: "1.15em"
    }
  }), label, count != null && /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--font-mono)",
      fontSize: "var(--fs-2xs)",
      opacity: 0.7
    }
  }, count));
}
Object.assign(__ds_scope, { FilterChip });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/controls/FilterChip.jsx", error: String((e && e.message) || e) }); }

// components/controls/IconButton.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * LiveCanvas IconButton — circular icon-only control.
 * variant: "glass" (blurred, sits over content) | "solid" (raised surface) | "ghost"
 * When `active`, favorites-style controls fill with the blush favorite color.
 */
function IconButton({
  icon,
  activeIcon,
  active = false,
  variant = "glass",
  size = 44,
  label,
  onClick,
  style,
  ...rest
}) {
  const variants = {
    glass: {
      background: "rgba(20,16,30,0.44)",
      backdropFilter: "blur(var(--blur-bar))",
      WebkitBackdropFilter: "blur(var(--blur-bar))",
      border: "1px solid rgba(255,255,255,0.14)",
      color: "#fff"
    },
    solid: {
      background: "var(--bg-raised)",
      border: "1px solid var(--border-subtle)",
      color: "var(--text-primary)"
    },
    ghost: {
      background: "transparent",
      border: "none",
      color: "var(--text-secondary)"
    }
  };
  const activeStyle = active ? {
    background: "var(--favorite)",
    border: "1px solid transparent",
    color: "#fff",
    boxShadow: "0 4px 14px rgba(255,111,156,0.45)"
  } : {};
  const shown = active && activeIcon ? activeIcon : icon;
  const filled = active && !activeIcon;
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    "aria-label": label,
    onClick: onClick,
    style: {
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      width: size,
      height: size,
      borderRadius: "var(--r-pill)",
      cursor: "pointer",
      transition: "transform .12s ease, background .15s ease",
      WebkitTapHighlightColor: "transparent",
      flexShrink: 0,
      ...variants[variant],
      ...activeStyle,
      ...style
    },
    onMouseDown: e => e.currentTarget.style.transform = "scale(0.9)",
    onMouseUp: e => e.currentTarget.style.transform = "scale(1)",
    onMouseLeave: e => e.currentTarget.style.transform = "scale(1)"
  }, rest), /*#__PURE__*/React.createElement("i", {
    className: `${filled ? "ph-fill" : "ph"} ph-${shown}`,
    style: {
      fontSize: size * 0.46
    }
  }));
}
Object.assign(__ds_scope, { IconButton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/controls/IconButton.jsx", error: String((e && e.message) || e) }); }

// components/feedback/EmptyState.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * LiveCanvas EmptyState — centered placeholder for empty grids (e.g. no favorites yet).
 * Uses a duotone Phosphor glyph in an aurora-soft halo.
 */
function EmptyState({
  icon = "heart",
  title,
  description,
  actionLabel,
  onAction,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      justifyContent: "center",
      textAlign: "center",
      gap: 8,
      padding: "48px 32px",
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      width: 88,
      height: 88,
      borderRadius: "var(--r-pill)",
      background: "var(--aurora-soft)",
      border: "1px solid var(--border-subtle)",
      marginBottom: 8
    }
  }, /*#__PURE__*/React.createElement("i", {
    className: `ph-duotone ph-${icon}`,
    style: {
      fontSize: 40,
      color: "var(--iris-400)"
    }
  })), /*#__PURE__*/React.createElement("h3", {
    style: {
      fontFamily: "var(--font-display)",
      fontSize: "var(--fs-h2)",
      fontWeight: 600,
      color: "var(--text-primary)",
      margin: 0,
      letterSpacing: "-0.02em"
    }
  }, title), description && /*#__PURE__*/React.createElement("p", {
    style: {
      fontFamily: "var(--font-body)",
      fontSize: "var(--fs-body)",
      lineHeight: 1.45,
      color: "var(--text-secondary)",
      margin: 0,
      maxWidth: 260
    }
  }, description), actionLabel && /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 12
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Button, {
    variant: "secondary",
    onClick: onAction
  }, actionLabel)));
}
Object.assign(__ds_scope, { EmptyState });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/EmptyState.jsx", error: String((e && e.message) || e) }); }

// components/navigation/TabBar.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * LiveCanvas TabBar — glass bottom navigation.
 * items: [{ id, icon, label }]. Active tab uses filled Phosphor glyph + iris color.
 */
function TabBar({
  items = [],
  active,
  onChange,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("nav", _extends({
    style: {
      display: "flex",
      alignItems: "center",
      justifyContent: "space-around",
      height: "var(--tabbar-h)",
      padding: "0 8px",
      background: "rgba(18,16,26,0.72)",
      backdropFilter: "blur(var(--blur-bar))",
      WebkitBackdropFilter: "blur(var(--blur-bar))",
      borderTop: "1px solid var(--border-subtle)",
      ...style
    }
  }, rest), items.map(it => {
    const on = it.id === active;
    return /*#__PURE__*/React.createElement("button", {
      key: it.id,
      type: "button",
      onClick: () => onChange && onChange(it.id),
      style: {
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: 3,
        background: "none",
        border: "none",
        cursor: "pointer",
        padding: "6px 12px",
        color: on ? "var(--accent)" : "var(--text-tertiary)",
        transition: "color .15s ease",
        WebkitTapHighlightColor: "transparent"
      }
    }, /*#__PURE__*/React.createElement("i", {
      className: `${on ? "ph-fill" : "ph"} ph-${it.icon}`,
      style: {
        fontSize: 24
      }
    }), /*#__PURE__*/React.createElement("span", {
      style: {
        fontFamily: "var(--font-body)",
        fontSize: "var(--fs-2xs)",
        fontWeight: on ? 700 : 500
      }
    }, it.label));
  }));
}
Object.assign(__ds_scope, { TabBar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/TabBar.jsx", error: String((e && e.message) || e) }); }

// components/navigation/TopBar.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * LiveCanvas TopBar — screen header.
 * Shows either the brand wordmark (aurora gradient text) or a title, with optional
 * leading + trailing slots. `transparent` for overlaying full-bleed content.
 */
function TopBar({
  title,
  wordmark = false,
  leading,
  trailing,
  transparent = false,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("header", _extends({
    style: {
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      gap: 12,
      height: 56,
      padding: "0 var(--gutter)",
      background: transparent ? "transparent" : "var(--bg-app)",
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 10,
      minWidth: 0
    }
  }, leading, wordmark ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--font-display)",
      fontSize: 22,
      fontWeight: 600,
      letterSpacing: "-0.02em",
      background: "var(--aurora)",
      WebkitBackgroundClip: "text",
      backgroundClip: "text",
      WebkitTextFillColor: "transparent"
    }
  }, "LiveCanvas") : /*#__PURE__*/React.createElement("h1", {
    style: {
      fontFamily: "var(--font-display)",
      fontSize: "var(--fs-h1)",
      fontWeight: 600,
      letterSpacing: "-0.02em",
      color: "var(--text-primary)",
      margin: 0,
      whiteSpace: "nowrap",
      overflow: "hidden",
      textOverflow: "ellipsis"
    }
  }, title)), trailing && /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8,
      flexShrink: 0
    }
  }, trailing));
}
Object.assign(__ds_scope, { TopBar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/TopBar.jsx", error: String((e && e.message) || e) }); }

// components/wallpaper/MetaChip.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * LiveCanvas MetaChip — small mono metadata pill for wallpaper specs.
 * Duration ("0:08"), resolution ("4K"), file size, live indicator, etc.
 * tone: "glass" (over content) | "surface" (on dark UI)
 */
function MetaChip({
  children,
  icon,
  tone = "glass",
  live = false,
  style,
  ...rest
}) {
  const tones = {
    glass: {
      background: "rgba(13,10,19,0.55)",
      backdropFilter: "blur(10px)",
      WebkitBackdropFilter: "blur(10px)",
      color: "#F6F3FB",
      border: "1px solid rgba(255,255,255,0.12)"
    },
    surface: {
      background: "var(--bg-raised)",
      color: "var(--text-secondary)",
      border: "1px solid var(--border-subtle)"
    }
  };
  return /*#__PURE__*/React.createElement("span", _extends({
    style: {
      display: "inline-flex",
      alignItems: "center",
      gap: 5,
      height: 22,
      padding: "0 8px",
      borderRadius: "var(--r-sm)",
      fontFamily: "var(--font-mono)",
      fontSize: "var(--fs-xs)",
      fontWeight: 400,
      letterSpacing: "0.02em",
      lineHeight: 1,
      ...tones[tone],
      ...style
    }
  }, rest), live && /*#__PURE__*/React.createElement("span", {
    style: {
      width: 6,
      height: 6,
      borderRadius: "var(--r-pill)",
      background: "var(--aqua-500)",
      boxShadow: "0 0 6px var(--aqua-500)"
    }
  }), icon && /*#__PURE__*/React.createElement("i", {
    className: `ph ph-${icon}`,
    style: {
      fontSize: "1.15em"
    }
  }), children);
}
Object.assign(__ds_scope, { MetaChip });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/wallpaper/MetaChip.jsx", error: String((e && e.message) || e) }); }

// components/wallpaper/PremiumBadge.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * LiveCanvas PremiumBadge — the "PRO" marker that distinguishes premium content.
 * No lock icon: an iridescent aurora-gradient tag readable in one glance.
 * variant: "tag" (default pill) | "dot" (compact corner gem)
 */
function PremiumBadge({
  variant = "tag",
  label = "PRO",
  style,
  ...rest
}) {
  if (variant === "dot") {
    return /*#__PURE__*/React.createElement("span", _extends({
      style: {
        display: "inline-flex",
        alignItems: "center",
        justifyContent: "center",
        width: 22,
        height: 22,
        borderRadius: "var(--r-pill)",
        background: "var(--aurora)",
        boxShadow: "0 2px 8px rgba(124,92,255,0.5)",
        color: "#fff",
        ...style
      }
    }, rest), /*#__PURE__*/React.createElement("i", {
      className: "ph-fill ph-diamond",
      style: {
        fontSize: 11
      }
    }));
  }
  return /*#__PURE__*/React.createElement("span", _extends({
    style: {
      display: "inline-flex",
      alignItems: "center",
      gap: 4,
      height: 22,
      padding: "0 9px",
      borderRadius: "var(--r-pill)",
      background: "var(--aurora)",
      color: "#fff",
      fontFamily: "var(--font-body)",
      fontSize: "var(--fs-2xs)",
      fontWeight: 700,
      letterSpacing: "0.1em",
      boxShadow: "0 2px 10px rgba(124,92,255,0.45)",
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("i", {
    className: "ph-fill ph-diamond",
    style: {
      fontSize: 10
    }
  }), label);
}
Object.assign(__ds_scope, { PremiumBadge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/wallpaper/PremiumBadge.jsx", error: String((e && e.message) || e) }); }

// components/wallpaper/WallpaperCard.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * LiveCanvas WallpaperCard — the signature 9:16 tile.
 * Casts an "Aura": a large, soft, content-derived glow (a blurred clone of the preview),
 * so the grid looks lit from within by the moving content itself.
 * Premium tiles carry an iridescent hairline ring + PRO tag (no lock).
 *
 * `preview` is any CSS background (a gradient stands in for the looping video in mocks).
 * `auraColor` sets the glow hue (in production, sampled from the video's dominant color).
 */
function WallpaperCard({
  preview = "linear-gradient(160deg,#7C5CFF,#46D5E6)",
  auraColor = "rgba(124,92,255,0.6)",
  title,
  author,
  premium = false,
  favorite = false,
  duration = "0:08",
  live = true,
  width = 168,
  onClick,
  onFavorite,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      position: "relative",
      width,
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    "aria-hidden": true,
    style: {
      position: "absolute",
      left: "8%",
      right: "8%",
      top: "10%",
      bottom: "-4%",
      background: auraColor,
      filter: "blur(26px)",
      borderRadius: "var(--r-xl)",
      opacity: 0.85,
      zIndex: 0,
      pointerEvents: "none"
    }
  }), /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onClick,
    style: {
      position: "relative",
      zIndex: 1,
      display: "block",
      width: "100%",
      aspectRatio: "9 / 16",
      border: premium ? "1.5px solid transparent" : "1px solid var(--border-subtle)",
      borderRadius: "var(--r-lg)",
      overflow: "hidden",
      padding: 0,
      cursor: "pointer",
      background: preview,
      backgroundSize: "cover",
      backgroundPosition: "center",
      WebkitTapHighlightColor: "transparent",
      transition: "transform .16s ease",
      boxShadow: premium ? "inset 0 0 0 1.5px rgba(255,255,255,0.25)" : "none"
    },
    onMouseDown: e => e.currentTarget.style.transform = "scale(0.97)",
    onMouseUp: e => e.currentTarget.style.transform = "scale(1)",
    onMouseLeave: e => e.currentTarget.style.transform = "scale(1)"
  }, premium && /*#__PURE__*/React.createElement("span", {
    "aria-hidden": true,
    style: {
      position: "absolute",
      inset: 0,
      borderRadius: "var(--r-lg)",
      padding: 1.5,
      background: "var(--aurora)",
      WebkitMask: "linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0)",
      WebkitMaskComposite: "xor",
      maskComposite: "exclude",
      pointerEvents: "none"
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      top: 8,
      left: 8,
      right: 8,
      display: "flex",
      justifyContent: "space-between",
      alignItems: "flex-start"
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.MetaChip, {
    live: live
  }, duration), premium && /*#__PURE__*/React.createElement(__ds_scope.PremiumBadge, null)), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      left: 0,
      right: 0,
      bottom: 0,
      padding: "26px 12px 10px",
      background: "linear-gradient(to top, rgba(9,7,14,0.78), transparent)",
      textAlign: "left"
    }
  }, title && /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: "var(--font-body)",
      fontSize: "var(--fs-sm)",
      fontWeight: 700,
      color: "#fff",
      lineHeight: 1.2
    }
  }, title), author && /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: "var(--font-body)",
      fontSize: "var(--fs-2xs)",
      color: "rgba(246,243,251,0.72)",
      marginTop: 2
    }
  }, author))), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      right: 8,
      bottom: 10,
      zIndex: 2
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.IconButton, {
    icon: "heart",
    active: favorite,
    size: 36,
    label: "Y\xEAu th\xEDch",
    onClick: onFavorite
  })));
}
Object.assign(__ds_scope, { WallpaperCard });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/wallpaper/WallpaperCard.jsx", error: String((e && e.message) || e) }); }

// ui_kits/livecanvas_app/Browse.jsx
try { (() => {
const {
  TopBar,
  IconButton,
  FilterChip,
  WallpaperCard
} = window.LiveCanvasDesignSystem_1b7873;
function ChipRail({
  chips,
  active,
  onPick
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 8,
      overflowX: "auto",
      padding: "4px 16px 12px",
      scrollbarWidth: "none"
    }
  }, chips.map(c => /*#__PURE__*/React.createElement(FilterChip, {
    key: c,
    label: c,
    active: c === active,
    onClick: () => onPick(c)
  })));
}
function SectionGrid({
  title,
  items,
  favs,
  onOpen,
  onFav
}) {
  return /*#__PURE__*/React.createElement("section", {
    style: {
      padding: "0 16px",
      marginBottom: 26
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "baseline",
      justifyContent: "space-between",
      marginBottom: 12
    }
  }, /*#__PURE__*/React.createElement("h2", {
    style: {
      fontFamily: "var(--font-display)",
      fontSize: 22,
      fontWeight: 600,
      letterSpacing: "-0.02em",
      color: "var(--text-primary)",
      margin: 0
    }
  }, title), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--font-mono)",
      fontSize: 11,
      color: "var(--text-tertiary)"
    }
  }, items.length)), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "grid",
      gridTemplateColumns: "1fr 1fr",
      gap: 12
    }
  }, items.map(w => /*#__PURE__*/React.createElement(WallpaperCard, {
    key: w.id,
    width: "100%",
    preview: w.preview,
    auraColor: w.aura,
    title: w.title,
    author: w.author,
    duration: w.duration,
    premium: w.premium,
    favorite: favs.has(w.id),
    onClick: () => onOpen(w),
    onFavorite: () => onFav(w.id)
  }))));
}
function Browse({
  favs,
  onOpen,
  onFav,
  onSearch
}) {
  const [chip, setChip] = React.useState("Tất cả");
  const D = window.LC_DATA;
  const filtered = items => chip === "Tất cả" ? items : items.filter(w => w.tag === chip);
  const sections = D.sections.map(s => ({
    ...s,
    items: filtered(s.items)
  })).filter(s => s.items.length);
  return /*#__PURE__*/React.createElement("div", {
    style: {
      height: "100%",
      overflowY: "auto",
      background: "var(--bg-app)"
    }
  }, /*#__PURE__*/React.createElement(TopBar, {
    wordmark: true,
    trailing: /*#__PURE__*/React.createElement(IconButton, {
      icon: "magnifying-glass",
      variant: "ghost",
      onClick: onSearch
    })
  }), /*#__PURE__*/React.createElement(ChipRail, {
    chips: D.chips,
    active: chip,
    onPick: setChip
  }), sections.map(s => /*#__PURE__*/React.createElement(SectionGrid, {
    key: s.title,
    title: s.title,
    items: s.items,
    favs: favs,
    onOpen: onOpen,
    onFav: onFav
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 12
    }
  }));
}
Object.assign(window, {
  Browse,
  ChipRail,
  SectionGrid
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/livecanvas_app/Browse.jsx", error: String((e && e.message) || e) }); }

// ui_kits/livecanvas_app/Favorites.jsx
try { (() => {
const {
  TopBar,
  WallpaperCard,
  EmptyState
} = window.LiveCanvasDesignSystem_1b7873;
function Favorites({
  favs,
  onOpen,
  onFav,
  onBrowse
}) {
  const items = window.LC_ALL.filter(w => favs.has(w.id));
  return /*#__PURE__*/React.createElement("div", {
    style: {
      height: "100%",
      overflowY: "auto",
      background: "var(--bg-app)"
    }
  }, /*#__PURE__*/React.createElement(TopBar, {
    title: "Y\xEAu th\xEDch",
    trailing: items.length ? /*#__PURE__*/React.createElement("span", {
      style: {
        fontFamily: "var(--font-mono)",
        fontSize: 12,
        color: "var(--text-tertiary)"
      }
    }, items.length) : null
  }), items.length === 0 ? /*#__PURE__*/React.createElement("div", {
    style: {
      paddingTop: 40
    }
  }, /*#__PURE__*/React.createElement(EmptyState, {
    icon: "heart",
    title: "Ch\u01B0a c\xF3 g\xEC \u1EDF \u0111\xE2y",
    description: "Ch\u1EA1m v\xE0o \u2665 tr\xEAn b\u1EA5t k\u1EF3 h\xECnh n\u1EC1n n\xE0o \u0111\u1EC3 l\u01B0u l\u1EA1i \u0111\xE2y.",
    actionLabel: "Kh\xE1m ph\xE1 h\xECnh n\u1EC1n",
    onAction: onBrowse
  })) : /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "4px 16px 16px"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "grid",
      gridTemplateColumns: "1fr 1fr",
      gap: 12
    }
  }, items.map(w => /*#__PURE__*/React.createElement(WallpaperCard, {
    key: w.id,
    width: "100%",
    preview: w.preview,
    auraColor: w.aura,
    title: w.title,
    author: w.author,
    duration: w.duration,
    premium: w.premium,
    favorite: true,
    onClick: () => onOpen(w),
    onFavorite: () => onFav(w.id)
  })))));
}
Object.assign(window, {
  Favorites
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/livecanvas_app/Favorites.jsx", error: String((e && e.message) || e) }); }

// ui_kits/livecanvas_app/Paywall.jsx
try { (() => {
const {
  IconButton,
  Button,
  PremiumBadge
} = window.LiveCanvasDesignSystem_1b7873;
function PerkRow({
  label,
  free,
  pro
}) {
  const mark = (on, color) => on ? /*#__PURE__*/React.createElement("i", {
    className: "ph-fill ph-check-circle",
    style: {
      fontSize: 20,
      color
    }
  }) : /*#__PURE__*/React.createElement("i", {
    className: "ph ph-minus",
    style: {
      fontSize: 18,
      color: "var(--text-tertiary)"
    }
  });
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "grid",
      gridTemplateColumns: "1fr 56px 56px",
      alignItems: "center",
      padding: "13px 0",
      borderBottom: "1px solid var(--border-subtle)"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--font-body)",
      fontSize: 14,
      color: "var(--text-primary)"
    }
  }, label), /*#__PURE__*/React.createElement("span", {
    style: {
      textAlign: "center"
    }
  }, mark(free, "var(--text-secondary)")), /*#__PURE__*/React.createElement("span", {
    style: {
      textAlign: "center"
    }
  }, mark(pro, "var(--iris-400)")));
}
function Paywall({
  onClose,
  onBuy
}) {
  const [plan, setPlan] = React.useState("year");
  const plans = {
    month: {
      label: "Hàng tháng",
      price: "59.000₫",
      sub: "mỗi tháng"
    },
    year: {
      label: "Hàng năm",
      price: "299.000₫",
      sub: "mỗi năm · tiết kiệm 58%",
      badge: "Phổ biến"
    }
  };
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      inset: 0,
      background: "var(--bg-app)",
      overflowY: "auto"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative",
      padding: "16px 20px 28px",
      background: "radial-gradient(120% 80% at 50% 0%, rgba(124,92,255,0.35), transparent 70%)"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      justifyContent: "flex-end"
    }
  }, /*#__PURE__*/React.createElement(IconButton, {
    icon: "x",
    variant: "solid",
    onClick: onClose,
    label: "\u0110\xF3ng"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: "center",
      marginTop: 8
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "inline-flex",
      marginBottom: 16
    }
  }, /*#__PURE__*/React.createElement(PremiumBadge, {
    label: "PREMIUM"
  })), /*#__PURE__*/React.createElement("h1", {
    style: {
      fontFamily: "var(--font-display)",
      fontSize: 34,
      fontWeight: 600,
      letterSpacing: "-0.02em",
      lineHeight: 1.08,
      color: "#fff",
      margin: "0 auto",
      maxWidth: 300
    }
  }, "M\u1EDF kho\xE1 c\u1EA3 kho h\xECnh n\u1EC1n s\u1ED1ng \u0111\u1ED9ng"), /*#__PURE__*/React.createElement("p", {
    style: {
      fontFamily: "var(--font-body)",
      fontSize: 15,
      lineHeight: 1.45,
      color: "var(--text-secondary)",
      margin: "10px auto 0",
      maxWidth: 300
    }
  }, "To\xE0n b\u1ED9 n\u1ED9i dung 4K, t\u1EA3i kh\xF4ng gi\u1EDBi h\u1EA1n, kh\xF4ng qu\u1EA3ng c\xE1o."))), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "0 20px"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "grid",
      gridTemplateColumns: "1fr 56px 56px",
      alignItems: "center",
      paddingBottom: 8
    }
  }, /*#__PURE__*/React.createElement("span", null), /*#__PURE__*/React.createElement("span", {
    style: {
      textAlign: "center",
      fontFamily: "var(--font-mono)",
      fontSize: 11,
      color: "var(--text-tertiary)"
    }
  }, "FREE"), /*#__PURE__*/React.createElement("span", {
    style: {
      textAlign: "center",
      fontFamily: "var(--font-mono)",
      fontSize: 11,
      fontWeight: 700,
      color: "var(--iris-400)"
    }
  }, "PRO")), /*#__PURE__*/React.createElement(PerkRow, {
    label: "H\xECnh n\u1EC1n mi\u1EC5n ph\xED",
    free: true,
    pro: true
  }), /*#__PURE__*/React.createElement(PerkRow, {
    label: "B\u1ED9 s\u01B0u t\u1EADp Premium 4K",
    free: false,
    pro: true
  }), /*#__PURE__*/React.createElement(PerkRow, {
    label: "T\u1EA3i xu\u1ED1ng kh\xF4ng gi\u1EDBi h\u1EA1n",
    free: false,
    pro: true
  }), /*#__PURE__*/React.createElement(PerkRow, {
    label: "Kh\xF4ng qu\u1EA3ng c\xE1o",
    free: false,
    pro: true
  }), /*#__PURE__*/React.createElement(PerkRow, {
    label: "N\u1ED9i dung m\u1EDBi m\u1ED7i tu\u1EA7n",
    free: false,
    pro: true
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "22px 20px 0",
      display: "flex",
      flexDirection: "column",
      gap: 10
    }
  }, Object.entries(plans).map(([k, p]) => {
    const on = k === plan;
    return /*#__PURE__*/React.createElement("button", {
      key: k,
      type: "button",
      onClick: () => setPlan(k),
      style: {
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
        textAlign: "left",
        padding: "14px 16px",
        borderRadius: "var(--r-md)",
        cursor: "pointer",
        background: on ? "var(--aurora-soft)" : "var(--bg-raised)",
        border: on ? "1.5px solid var(--iris-500)" : "1px solid var(--border-subtle)"
      }
    }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
      style: {
        display: "flex",
        alignItems: "center",
        gap: 8
      }
    }, /*#__PURE__*/React.createElement("span", {
      style: {
        fontFamily: "var(--font-body)",
        fontSize: 15,
        fontWeight: 700,
        color: "var(--text-primary)"
      }
    }, p.label), p.badge && /*#__PURE__*/React.createElement("span", {
      style: {
        fontFamily: "var(--font-mono)",
        fontSize: 10,
        fontWeight: 700,
        color: "#fff",
        background: "var(--aurora)",
        padding: "2px 7px",
        borderRadius: "var(--r-pill)"
      }
    }, p.badge)), /*#__PURE__*/React.createElement("div", {
      style: {
        fontFamily: "var(--font-body)",
        fontSize: 12,
        color: "var(--text-secondary)",
        marginTop: 2
      }
    }, p.sub)), /*#__PURE__*/React.createElement("div", {
      style: {
        fontFamily: "var(--font-display)",
        fontSize: 22,
        fontWeight: 600,
        color: "var(--text-primary)"
      }
    }, p.price));
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "18px 20px 8px"
    }
  }, /*#__PURE__*/React.createElement(Button, {
    variant: "aurora",
    icon: "sparkle",
    fullWidth: true,
    onClick: onBuy
  }, "B\u1EAFt \u0111\u1EA7u d\xF9ng Premium")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      justifyContent: "center",
      gap: 20,
      padding: "6px 20px 28px"
    }
  }, /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onClose,
    style: {
      background: "none",
      border: "none",
      cursor: "pointer",
      fontFamily: "var(--font-body)",
      fontSize: 13,
      color: "var(--text-secondary)"
    }
  }, "Kh\xF4i ph\u1EE5c giao d\u1ECBch"), /*#__PURE__*/React.createElement("span", {
    style: {
      color: "var(--text-tertiary)"
    }
  }, "\xB7"), /*#__PURE__*/React.createElement("button", {
    type: "button",
    style: {
      background: "none",
      border: "none",
      cursor: "pointer",
      fontFamily: "var(--font-body)",
      fontSize: 13,
      color: "var(--text-secondary)"
    }
  }, "\u0110i\u1EC1u kho\u1EA3n")));
}
Object.assign(window, {
  Paywall,
  PerkRow
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/livecanvas_app/Paywall.jsx", error: String((e && e.message) || e) }); }

// ui_kits/livecanvas_app/Search.jsx
try { (() => {
const {
  TopBar,
  IconButton,
  FilterChip,
  WallpaperCard,
  EmptyState
} = window.LiveCanvasDesignSystem_1b7873;
function Search({
  favs,
  onOpen,
  onFav,
  onBack
}) {
  const [q, setQ] = React.useState("");
  const D = window.LC_DATA;
  const results = q.trim() ? window.LC_ALL.filter(w => (w.title + " " + w.tag + " " + w.author).toLowerCase().includes(q.toLowerCase())) : [];
  return /*#__PURE__*/React.createElement("div", {
    style: {
      height: "100%",
      overflowY: "auto",
      background: "var(--bg-app)"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 10,
      padding: "12px 16px 8px"
    }
  }, /*#__PURE__*/React.createElement(IconButton, {
    icon: "arrow-left",
    variant: "ghost",
    onClick: onBack,
    label: "Quay l\u1EA1i"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: "flex",
      alignItems: "center",
      gap: 8,
      height: 44,
      padding: "0 14px",
      background: "var(--bg-raised)",
      border: "1px solid var(--border-subtle)",
      borderRadius: "var(--r-pill)"
    }
  }, /*#__PURE__*/React.createElement("i", {
    className: "ph ph-magnifying-glass",
    style: {
      fontSize: 18,
      color: "var(--text-tertiary)"
    }
  }), /*#__PURE__*/React.createElement("input", {
    autoFocus: true,
    value: q,
    onChange: e => setQ(e.target.value),
    placeholder: "T\xECm h\xECnh n\u1EC1n, tag, t\xE1c gi\u1EA3\u2026",
    style: {
      flex: 1,
      background: "none",
      border: "none",
      outline: "none",
      color: "var(--text-primary)",
      fontFamily: "var(--font-body)",
      fontSize: 15
    }
  }), q && /*#__PURE__*/React.createElement("i", {
    className: "ph-fill ph-x-circle",
    onClick: () => setQ(""),
    style: {
      fontSize: 18,
      color: "var(--text-tertiary)",
      cursor: "pointer"
    }
  }))), !q.trim() && /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "16px"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: "var(--font-mono)",
      fontSize: 11,
      letterSpacing: "0.08em",
      textTransform: "uppercase",
      color: "var(--text-tertiary)",
      marginBottom: 12
    }
  }, "G\u1EE3i \xFD cho b\u1EA1n"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexWrap: "wrap",
      gap: 8
    }
  }, D.suggestions.map(s => /*#__PURE__*/React.createElement(FilterChip, {
    key: s,
    label: s,
    icon: "magnifying-glass",
    onClick: () => setQ(s.split(" ")[0])
  })))), q.trim() && results.length > 0 && /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "4px 16px 16px"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: "var(--font-mono)",
      fontSize: 11,
      color: "var(--text-tertiary)",
      marginBottom: 12
    }
  }, results.length, " k\u1EBFt qu\u1EA3 cho \u201C", q, "\u201D"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "grid",
      gridTemplateColumns: "1fr 1fr",
      gap: 12
    }
  }, results.map(w => /*#__PURE__*/React.createElement(WallpaperCard, {
    key: w.id,
    width: "100%",
    preview: w.preview,
    auraColor: w.aura,
    title: w.title,
    author: w.author,
    duration: w.duration,
    premium: w.premium,
    favorite: favs.has(w.id),
    onClick: () => onOpen(w),
    onFavorite: () => onFav(w.id)
  })))), q.trim() && results.length === 0 && /*#__PURE__*/React.createElement(EmptyState, {
    icon: "magnifying-glass",
    title: "Kh\xF4ng t\xECm th\u1EA5y",
    description: `Không có kết quả cho “${q}”. Thử từ khoá khác hoặc chọn một gợi ý.`
  }));
}
Object.assign(window, {
  Search
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/livecanvas_app/Search.jsx", error: String((e && e.message) || e) }); }

// ui_kits/livecanvas_app/SetWallpaper.jsx
try { (() => {
const {
  Button,
  IconButton
} = window.LiveCanvasDesignSystem_1b7873;

// Set-wallpaper flow. iOS and Android differ at the OS level, so the sheet tells the
// user which path they're on without making it feel like a limitation.
function SetWallpaper({
  wall,
  onClose
}) {
  const [os, setOs] = React.useState("android");
  const [done, setDone] = React.useState(false);
  const Seg = ({
    id,
    icon,
    label
  }) => /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: () => {
      setOs(id);
      setDone(false);
    },
    style: {
      flex: 1,
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      gap: 6,
      height: 38,
      borderRadius: "var(--r-sm)",
      cursor: "pointer",
      border: "none",
      background: os === id ? "var(--bg-app)" : "transparent",
      color: os === id ? "var(--text-primary)" : "var(--text-tertiary)",
      fontFamily: "var(--font-body)",
      fontSize: 14,
      fontWeight: 700
    }
  }, /*#__PURE__*/React.createElement("i", {
    className: `ph ph-${icon}`,
    style: {
      fontSize: 18
    }
  }), label);
  const Step = ({
    n,
    children
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 12,
      alignItems: "flex-start",
      padding: "10px 0"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flexShrink: 0,
      width: 26,
      height: 26,
      borderRadius: "var(--r-pill)",
      background: "var(--aurora-soft)",
      border: "1px solid var(--border-subtle)",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      fontFamily: "var(--font-mono)",
      fontSize: 12,
      fontWeight: 700,
      color: "var(--iris-400)"
    }
  }, n), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--font-body)",
      fontSize: 14,
      lineHeight: 1.45,
      color: "var(--text-secondary)",
      paddingTop: 2
    }
  }, children));
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      inset: 0,
      background: "rgba(9,7,14,0.6)",
      backdropFilter: "blur(4px)",
      display: "flex",
      alignItems: "flex-end"
    },
    onClick: onClose
  }, /*#__PURE__*/React.createElement("div", {
    onClick: e => e.stopPropagation(),
    style: {
      width: "100%",
      background: "var(--bg-surface)",
      borderTopLeftRadius: "var(--r-xl)",
      borderTopRightRadius: "var(--r-xl)",
      boxShadow: "var(--shadow-sheet)",
      padding: "10px 20px 24px",
      maxHeight: "84%",
      overflowY: "auto"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 40,
      height: 4,
      borderRadius: 2,
      background: "var(--border-strong)",
      margin: "0 auto 16px"
    }
  }), done ? /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: "center",
      padding: "16px 0 8px"
    }
  }, /*#__PURE__*/React.createElement("i", {
    className: "ph-fill ph-check-circle",
    style: {
      fontSize: 56,
      color: "var(--success)"
    }
  }), /*#__PURE__*/React.createElement("h2", {
    style: {
      fontFamily: "var(--font-display)",
      fontSize: 24,
      fontWeight: 600,
      color: "var(--text-primary)",
      margin: "12px 0 4px"
    }
  }, "\u0110\xE3 t\u1EA3i xu\u1ED1ng"), /*#__PURE__*/React.createElement("p", {
    style: {
      fontFamily: "var(--font-body)",
      fontSize: 14,
      color: "var(--text-secondary)",
      margin: "0 auto 20px",
      maxWidth: 260
    }
  }, os === "android" ? "Chạm tiếp tục để đặt “" + wall.title + "” làm hình nền động ngay bây giờ." : "Làm theo các bước bên dưới để đặt qua Shortcuts."), os === "android" ? /*#__PURE__*/React.createElement(Button, {
    variant: "primary",
    icon: "paint-brush-broad",
    fullWidth: true,
    onClick: onClose
  }, "\u0110\u1EB7t l\xE0m h\xECnh n\u1EC1n") : /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: "left"
    }
  }, /*#__PURE__*/React.createElement(Step, {
    n: "1"
  }, "M\u1EDF \u1EE9ng d\u1EE5ng ", /*#__PURE__*/React.createElement("b", {
    style: {
      color: "var(--text-primary)"
    }
  }, "Ph\xEDm t\u1EAFt"), " (Shortcuts) c\u1EE7a iOS."), /*#__PURE__*/React.createElement(Step, {
    n: "2"
  }, "T\u1EA1o ph\xEDm t\u1EAFt ", /*#__PURE__*/React.createElement("b", {
    style: {
      color: "var(--text-primary)"
    }
  }, "\u0110\u1EB7t h\xECnh n\u1EC1n"), " \u2192 ch\u1ECDn video v\u1EEBa l\u01B0u."), /*#__PURE__*/React.createElement(Step, {
    n: "3"
  }, "Ch\u1EA1y ph\xEDm t\u1EAFt v\xE0o gi\u1EDD b\u1EA1n mu\u1ED1n \u2014 h\xECnh n\u1EC1n s\u1EBD chuy\u1EC3n \u0111\u1ED9ng tr\xEAn m\xE0n kho\xE1."), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 14
    }
  }, /*#__PURE__*/React.createElement(Button, {
    variant: "secondary",
    icon: "arrow-square-out",
    fullWidth: true,
    onClick: onClose
  }, "M\u1EDF Shortcuts")))) : /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      marginBottom: 14
    }
  }, /*#__PURE__*/React.createElement("h2", {
    style: {
      fontFamily: "var(--font-display)",
      fontSize: 22,
      fontWeight: 600,
      color: "var(--text-primary)",
      margin: 0
    }
  }, "\u0110\u1EB7t l\xE0m h\xECnh n\u1EC1n"), /*#__PURE__*/React.createElement(IconButton, {
    icon: "x",
    variant: "ghost",
    onClick: onClose
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 4,
      padding: 4,
      background: "var(--bg-raised)",
      borderRadius: "var(--r-md)",
      border: "1px solid var(--border-subtle)",
      marginBottom: 8
    }
  }, /*#__PURE__*/React.createElement(Seg, {
    id: "android",
    icon: "android-logo",
    label: "Android"
  }), /*#__PURE__*/React.createElement(Seg, {
    id: "ios",
    icon: "apple-logo",
    label: "iPhone"
  })), /*#__PURE__*/React.createElement("p", {
    style: {
      fontFamily: "var(--font-body)",
      fontSize: 13,
      lineHeight: 1.45,
      color: "var(--text-tertiary)",
      margin: "0 0 8px"
    }
  }, os === "android" ? "Trên Android, LiveCanvas đặt hình nền động trực tiếp — chỉ một chạm." : "iOS không cho app đặt video làm hình nền trực tiếp. LiveCanvas lưu video rồi hướng dẫn bạn đặt qua Shortcuts (một lần thiết lập)."), /*#__PURE__*/React.createElement("div", {
    style: {
      margin: "12px 0"
    }
  }, /*#__PURE__*/React.createElement(Button, {
    variant: "primary",
    icon: "download-simple",
    fullWidth: true,
    onClick: () => setDone(true)
  }, os === "android" ? "Tải & đặt hình nền" : "Lưu video vào Ảnh")))));
}
Object.assign(window, {
  SetWallpaper
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/livecanvas_app/SetWallpaper.jsx", error: String((e && e.message) || e) }); }

// ui_kits/livecanvas_app/WallpaperDetail.jsx
try { (() => {
const {
  IconButton,
  Button,
  MetaChip,
  PremiumBadge
} = window.LiveCanvasDesignSystem_1b7873;

// Full-screen wallpaper preview. The chrome (Aura glow + primary action) adopts the
// content's dominant hue — the app "wears" the wallpaper it's showing.
function WallpaperDetail({
  wall,
  favorite,
  subscribed,
  onFav,
  onBack,
  onSet,
  onPremium
}) {
  if (!wall) return null;
  const locked = wall.premium && !subscribed;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      inset: 0,
      background: "var(--bg-app)",
      overflow: "hidden",
      display: "flex",
      flexDirection: "column"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      inset: 0,
      background: wall.preview,
      backgroundSize: "cover"
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      left: "-20%",
      right: "-20%",
      top: "10%",
      height: "60%",
      background: wall.aura,
      filter: "blur(80px)",
      opacity: 0.5,
      pointerEvents: "none"
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      top: 0,
      left: 0,
      right: 0,
      height: 120,
      background: "linear-gradient(to bottom, rgba(9,7,14,0.6), transparent)"
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative",
      display: "flex",
      justifyContent: "space-between",
      alignItems: "center",
      padding: "14px 16px"
    }
  }, /*#__PURE__*/React.createElement(IconButton, {
    icon: "arrow-left",
    variant: "glass",
    onClick: onBack,
    label: "Quay l\u1EA1i"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 8
    }
  }, /*#__PURE__*/React.createElement(IconButton, {
    icon: "share-network",
    variant: "glass",
    label: "Chia s\u1EBB"
  }), /*#__PURE__*/React.createElement(IconButton, {
    icon: "heart",
    active: favorite,
    variant: "glass",
    onClick: onFav,
    label: "Y\xEAu th\xEDch"
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative",
      alignSelf: "center",
      marginTop: 4
    }
  }, /*#__PURE__*/React.createElement(MetaChip, {
    live: true
  }, wall.duration, " \xB7 LOOP")), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative",
      padding: "44px 20px 24px",
      background: "linear-gradient(to top, rgba(9,7,14,0.92) 55%, transparent)"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8,
      marginBottom: 8
    }
  }, wall.premium && /*#__PURE__*/React.createElement(PremiumBadge, null), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--font-mono)",
      fontSize: 11,
      color: "rgba(246,243,251,0.6)"
    }
  }, "#", wall.tag.toLowerCase())), /*#__PURE__*/React.createElement("h1", {
    style: {
      fontFamily: "var(--font-display)",
      fontSize: 32,
      fontWeight: 600,
      letterSpacing: "-0.02em",
      color: "#fff",
      margin: 0
    }
  }, wall.title), /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: "var(--font-body)",
      fontSize: 14,
      color: "rgba(246,243,251,0.7)",
      marginTop: 4
    }
  }, wall.author), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 8,
      margin: "16px 0 18px"
    }
  }, /*#__PURE__*/React.createElement(MetaChip, {
    icon: "monitor"
  }, wall.res), /*#__PURE__*/React.createElement(MetaChip, {
    icon: "clock"
  }, wall.duration), /*#__PURE__*/React.createElement(MetaChip, {
    icon: "download-simple"
  }, wall.size)), locked ? /*#__PURE__*/React.createElement(Button, {
    variant: "aurora",
    icon: "sparkle",
    fullWidth: true,
    onClick: onPremium
  }, "M\u1EDF kho\xE1 v\u1EDBi Premium") : /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 10
    }
  }, /*#__PURE__*/React.createElement(Button, {
    variant: "secondary",
    icon: "download-simple",
    onClick: onSet
  }, "T\u1EA3i xu\u1ED1ng"), /*#__PURE__*/React.createElement(Button, {
    variant: "primary",
    icon: "paint-brush-broad",
    fullWidth: true,
    style: {
      background: "#fff",
      color: "#141018",
      boxShadow: `0 8px 24px ${wall.aura}`
    },
    onClick: onSet
  }, "\u0110\u1EB7t l\xE0m h\xECnh n\u1EC1n"))));
}
Object.assign(window, {
  WallpaperDetail
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/livecanvas_app/WallpaperDetail.jsx", error: String((e && e.message) || e) }); }

// ui_kits/livecanvas_app/data.js
try { (() => {
// LiveCanvas UI-kit sample data. Gradient `preview` values stand in for the looping
// 9:16 videos; `aura` is the color the tile glow (and detail-screen chrome) adopts.
window.LC_DATA = {
  chips: ["Tất cả", "Neon", "Thiên nhiên", "Không gian", "Trừu tượng", "Tối giản", "Anime"],
  suggestions: ["neon rain", "aurora", "sakura", "galaxy", "lofi", "waterfall", "cyberpunk", "ocean"],
  sections: [{
    title: "Xu hướng tuần này",
    items: [{
      id: "w1",
      title: "Neon Rain",
      author: "@studiolux",
      preview: "linear-gradient(155deg,#FF6F9C,#7C5CFF 55%,#241E33)",
      aura: "rgba(255,111,156,0.62)",
      duration: "0:08",
      res: "4K",
      size: "12MB",
      premium: false,
      tag: "Neon"
    }, {
      id: "w2",
      title: "Aurora Drift",
      author: "@nord",
      preview: "linear-gradient(155deg,#46D5E6,#3FE0A6 55%,#0E3B39)",
      aura: "rgba(70,213,230,0.55)",
      duration: "0:12",
      res: "4K",
      size: "18MB",
      premium: true,
      tag: "Thiên nhiên"
    }, {
      id: "w3",
      title: "Deep Field",
      author: "@cosmos",
      preview: "linear-gradient(155deg,#7C5CFF,#2A1E4A 60%,#0D0A13)",
      aura: "rgba(124,92,255,0.6)",
      duration: "0:10",
      res: "4K",
      size: "15MB",
      premium: false,
      tag: "Không gian"
    }, {
      id: "w4",
      title: "Liquid Gold",
      author: "@fluidco",
      preview: "linear-gradient(155deg,#FFC24C,#FF6F9C 60%,#3A1E2E)",
      aura: "rgba(255,194,76,0.55)",
      duration: "0:06",
      res: "2K",
      size: "8MB",
      premium: true,
      tag: "Trừu tượng"
    }]
  }, {
    title: "Neon về đêm",
    items: [{
      id: "w5",
      title: "Shibuya 2099",
      author: "@tokyo",
      preview: "linear-gradient(155deg,#FF6F9C,#46D5E6 65%,#12101A)",
      aura: "rgba(255,111,156,0.55)",
      duration: "0:09",
      res: "4K",
      size: "14MB",
      premium: false,
      tag: "Neon"
    }, {
      id: "w6",
      title: "Synth Highway",
      author: "@retro",
      preview: "linear-gradient(155deg,#7C5CFF,#FF6F9C 70%,#1A1626)",
      aura: "rgba(124,92,255,0.55)",
      duration: "0:11",
      res: "4K",
      size: "16MB",
      premium: true,
      tag: "Neon"
    }, {
      id: "w7",
      title: "Cyber Alley",
      author: "@blade",
      preview: "linear-gradient(155deg,#46D5E6,#7C5CFF 60%,#0D0A13)",
      aura: "rgba(70,213,230,0.5)",
      duration: "0:07",
      res: "2K",
      size: "9MB",
      premium: false,
      tag: "Neon"
    }, {
      id: "w8",
      title: "Pink Static",
      author: "@vhs",
      preview: "linear-gradient(155deg,#FF8FB2,#FF6F9C 55%,#2A1622)",
      aura: "rgba(255,143,178,0.55)",
      duration: "0:05",
      res: "2K",
      size: "7MB",
      premium: false,
      tag: "Neon"
    }]
  }, {
    title: "Thiên nhiên sống động",
    items: [{
      id: "w9",
      title: "Rừng mưa",
      author: "@wild",
      preview: "linear-gradient(155deg,#3FE0A6,#46D5E6 60%,#0E3B39)",
      aura: "rgba(63,224,166,0.5)",
      duration: "0:14",
      res: "4K",
      size: "22MB",
      premium: true,
      tag: "Thiên nhiên"
    }, {
      id: "w10",
      title: "Sakura Fall",
      author: "@kyoto",
      preview: "linear-gradient(155deg,#FF8FB2,#FFC24C 65%,#2A1E2E)",
      aura: "rgba(255,143,178,0.5)",
      duration: "0:10",
      res: "4K",
      size: "17MB",
      premium: false,
      tag: "Thiên nhiên"
    }, {
      id: "w11",
      title: "Sóng biển",
      author: "@pacific",
      preview: "linear-gradient(155deg,#46D5E6,#7C5CFF 70%,#0D2B33)",
      aura: "rgba(70,213,230,0.5)",
      duration: "0:12",
      res: "4K",
      size: "19MB",
      premium: false,
      tag: "Thiên nhiên"
    }, {
      id: "w12",
      title: "Thác đêm",
      author: "@mist",
      preview: "linear-gradient(155deg,#3FE0A6,#7C5CFF 65%,#101A26)",
      aura: "rgba(63,224,166,0.5)",
      duration: "0:13",
      res: "4K",
      size: "20MB",
      premium: true,
      tag: "Thiên nhiên"
    }]
  }]
};
window.LC_ALL = window.LC_DATA.sections.flatMap(s => s.items);
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/livecanvas_app/data.js", error: String((e && e.message) || e) }); }

__ds_ns.Button = __ds_scope.Button;

__ds_ns.FilterChip = __ds_scope.FilterChip;

__ds_ns.IconButton = __ds_scope.IconButton;

__ds_ns.EmptyState = __ds_scope.EmptyState;

__ds_ns.TabBar = __ds_scope.TabBar;

__ds_ns.TopBar = __ds_scope.TopBar;

__ds_ns.MetaChip = __ds_scope.MetaChip;

__ds_ns.PremiumBadge = __ds_scope.PremiumBadge;

__ds_ns.WallpaperCard = __ds_scope.WallpaperCard;

})();
