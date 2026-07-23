const { IconButton, Button, MetaChip, PremiumBadge, WallpaperCard } = window.LiveCanvasDesignSystem_1b7873;

// Animated stand-in for the looping 9:16 video: the gradient drifts + a soft light
// blob floats, so a still screenshot still reads as "this moves". auraColor bleeds behind.
function LivePreview({ wall, height }) {
  return (
    <div style={{ position: "relative", width: "100%", height, overflow: "hidden", background: "var(--void)" }}>
      <div className="lc-drift" style={{ position: "absolute", inset: "-10%", background: wall.preview, backgroundSize: "180% 180%" }} />
      <div className="lc-blob" style={{ position: "absolute", width: "60%", height: "40%", left: "20%", top: "22%", background: wall.aura, filter: "blur(60px)", borderRadius: "50%" }} />
      <div style={{ position: "absolute", inset: 0, background: "linear-gradient(to top, rgba(9,7,14,0.55), transparent 30%, transparent 70%, rgba(9,7,14,0.45))" }} />
    </div>
  );
}

function Stat({ icon, value, label }) {
  return (
    <div style={{ flex: 1, textAlign: "center" }}>
      <i className={`ph ph-${icon}`} style={{ fontSize: 20, color: "var(--iris-400)" }} />
      <div style={{ fontFamily: "var(--font-mono)", fontSize: 15, fontWeight: 700, color: "var(--text-primary)", marginTop: 4 }}>{value}</div>
      <div style={{ fontFamily: "var(--font-body)", fontSize: 11, color: "var(--text-tertiary)", marginTop: 1 }}>{label}</div>
    </div>
  );
}

function SectionLabel({ children, action, onAction }) {
  return (
    <div style={{ display: "flex", alignItems: "baseline", justifyContent: "space-between", margin: "0 0 12px" }}>
      <h2 style={{ fontFamily: "var(--font-display)", fontSize: 19, fontWeight: 600, letterSpacing: "-0.02em", color: "var(--text-primary)", margin: 0 }}>{children}</h2>
      {action && <button type="button" onClick={onAction} style={{ background: "none", border: "none", cursor: "pointer", fontFamily: "var(--font-body)", fontSize: 13, fontWeight: 600, color: "var(--iris-400)" }}>{action}</button>}
    </div>
  );
}

function WallpaperDetail({ wall, favorite, favs, subscribed, onFav, onBack, onSet, onPremium, onShare, onMore, onOpen, onCollection }) {
  if (!wall) return null;
  const locked = wall.premium && !subscribed;
  const coll = window.LC_COLL_OF(wall.id);
  const related = window.LC_RELATED(wall);
  const palette = window.LC_PALETTE(wall.preview);

  return (
    <div style={{ position: "absolute", inset: 0, background: "var(--bg-app)", overflowY: "auto" }}>
      {/* floating glass chrome — stays put while content scrolls */}
      <div style={{ position: "absolute", zIndex: 10, top: 0, left: 0, right: 0, display: "flex", justifyContent: "space-between", alignItems: "center", padding: "14px 16px" }}>
        <IconButton icon="arrow-left" variant="glass" onClick={onBack} label="Quay lại" />
        <div style={{ display: "flex", gap: 8 }}>
          <IconButton icon="share-network" variant="glass" onClick={onShare} label="Chia sẻ" />
          <IconButton icon="heart" active={favorite} variant="glass" onClick={onFav} label="Yêu thích" />
          <IconButton icon="dots-three-vertical" variant="glass" onClick={onMore} label="Thêm" />
        </div>
      </div>

      {/* sticky preview → parallax reveal as the sheet slides up over it */}
      <div style={{ position: "sticky", top: 0, zIndex: 1 }}>
        <LivePreview wall={wall} height={468} />
        {/* live loop badge + mute control float on the preview */}
        <div style={{ position: "absolute", top: 70, left: 0, right: 0, display: "flex", justifyContent: "center" }}>
          <MetaChip live>{wall.duration} · LOOP</MetaChip>
        </div>
        <div style={{ position: "absolute", bottom: 44, left: 0, right: 0, display: "flex", justifyContent: "center", gap: 8 }}>
          <IconButton icon="speaker-simple-x" variant="glass" size={40} label="Tắt tiếng" />
          <IconButton icon="arrow-clockwise" variant="glass" size={40} label="Phát lại" />
        </div>
      </div>

      {/* info sheet — overlaps the preview, carries the content hue in its top border */}
      <div style={{ position: "relative", zIndex: 2, marginTop: -32, borderTopLeftRadius: "var(--r-xl)", borderTopRightRadius: "var(--r-xl)", background: "var(--bg-app)", boxShadow: `0 -12px 40px ${wall.aura}`, padding: "10px 20px 28px" }}>
        <div style={{ width: 40, height: 4, borderRadius: 2, background: "var(--border-strong)", margin: "0 auto 18px" }} />

        <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 10 }}>
          {wall.premium && <PremiumBadge />}
          <span style={{ display: "inline-flex", alignItems: "center", height: 22, padding: "0 10px", borderRadius: "var(--r-pill)", background: "var(--bg-raised)", border: "1px solid var(--border-subtle)", fontFamily: "var(--font-body)", fontSize: 12, fontWeight: 600, color: "var(--text-secondary)" }}>#{wall.tag}</span>
        </div>

        <h1 style={{ fontFamily: "var(--font-display)", fontSize: 32, fontWeight: 600, letterSpacing: "-0.02em", color: "var(--text-primary)", margin: 0, lineHeight: 1.05 }}>{wall.title}</h1>

        {/* author row → jumps into the collection */}
        <button type="button" onClick={() => onCollection(coll)} style={{ display: "flex", alignItems: "center", gap: 10, width: "100%", textAlign: "left", background: "none", border: "none", cursor: "pointer", padding: "14px 0 4px" }}>
          <div style={{ width: 36, height: 36, borderRadius: "var(--r-pill)", background: "var(--aurora)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}><i className="ph-fill ph-user" style={{ fontSize: 17, color: "#fff" }} /></div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontFamily: "var(--font-body)", fontSize: 14, fontWeight: 700, color: "var(--text-primary)" }}>@{wall.author}</div>
            <div style={{ fontFamily: "var(--font-body)", fontSize: 12, color: "var(--text-tertiary)" }}>Từ bộ sưu tập · {coll.title}</div>
          </div>
          <i className="ph ph-caret-right" style={{ fontSize: 18, color: "var(--text-tertiary)" }} />
        </button>

        {/* meta chips */}
        <div style={{ display: "flex", gap: 8, margin: "16px 0 18px" }}>
          <MetaChip tone="surface" icon="monitor">{wall.res}</MetaChip>
          <MetaChip tone="surface" icon="clock">{wall.duration}</MetaChip>
          <MetaChip tone="surface" icon="download-simple">{wall.size}</MetaChip>
        </div>

        {/* primary actions */}
        {locked ? (
          <Button variant="aurora" icon="sparkle" fullWidth onClick={onPremium}>Mở khoá với Premium</Button>
        ) : (
          <div style={{ display: "flex", gap: 10 }}>
            <Button variant="secondary" icon="download-simple" onClick={onSet}>Tải xuống</Button>
            <Button variant="primary" icon="paint-brush-broad" fullWidth style={{ background: "#fff", color: "#141018", boxShadow: `0 8px 24px ${wall.aura}` }} onClick={onSet}>Đặt làm hình nền</Button>
          </div>
        )}

        {/* stats */}
        <div style={{ display: "flex", gap: 6, margin: "22px 0", padding: "16px 0", background: "var(--bg-surface)", borderRadius: "var(--r-md)", border: "1px solid var(--border-subtle)" }}>
          <Stat icon="download-simple" value={wall.downloads} label="Lượt tải" />
          <div style={{ width: 1, background: "var(--border-subtle)" }} />
          <Stat icon="heart" value={wall.likes} label="Yêu thích" />
          <div style={{ width: 1, background: "var(--border-subtle)" }} />
          <Stat icon="monitor-play" value={wall.res} label="Độ phân giải" />
        </div>

        {/* description */}
        <SectionLabel>Mô tả</SectionLabel>
        <p style={{ fontFamily: "var(--font-body)", fontSize: 14, lineHeight: 1.6, color: "var(--text-secondary)", margin: "0 0 8px", textWrap: "pretty" }}>{wall.desc}</p>

        {/* content palette */}
        <div style={{ display: "flex", gap: 8, alignItems: "center", margin: "16px 0 26px" }}>
          <span style={{ fontFamily: "var(--font-mono)", fontSize: 11, color: "var(--text-tertiary)", marginRight: 2 }}>PALETTE</span>
          {palette.map((c, i) => (
            <div key={i} style={{ display: "flex", alignItems: "center", gap: 6 }}>
              <span style={{ width: 20, height: 20, borderRadius: "var(--r-xs)", background: c, border: "1px solid var(--border-strong)" }} />
              <span style={{ fontFamily: "var(--font-mono)", fontSize: 10, color: "var(--text-tertiary)" }}>{c.replace("#", "")}</span>
            </div>
          ))}
        </div>

        {/* collection card */}
        <button type="button" onClick={() => onCollection(coll)} style={{ display: "flex", alignItems: "center", gap: 14, width: "100%", textAlign: "left", cursor: "pointer", padding: 12, marginBottom: 28, background: "var(--bg-surface)", border: "1px solid var(--border-subtle)", borderRadius: "var(--r-md)" }}>
          <div style={{ width: 52, height: 68, borderRadius: "var(--r-sm)", background: coll.cover, backgroundSize: "cover", flexShrink: 0, boxShadow: `0 6px 18px ${coll.aura}` }} />
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontFamily: "var(--font-mono)", fontSize: 10, color: "var(--text-tertiary)", letterSpacing: "0.08em" }}>BỘ SƯU TẬP</div>
            <div style={{ fontFamily: "var(--font-display)", fontSize: 17, fontWeight: 600, color: "var(--text-primary)", margin: "2px 0" }}>{coll.title}</div>
            <div style={{ fontFamily: "var(--font-body)", fontSize: 12, color: "var(--text-secondary)" }}>{coll.itemIds.length} hình nền</div>
          </div>
          <i className="ph ph-caret-right" style={{ fontSize: 20, color: "var(--text-tertiary)" }} />
        </button>

        {/* related */}
        <SectionLabel>Hình nền liên quan</SectionLabel>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
          {related.map((w) => (
            <WallpaperCard key={w.id} width="100%" preview={w.preview} auraColor={w.aura} title={w.title} author={"@" + w.author}
              duration={w.duration} premium={w.premium} favorite={favs ? favs.has(w.id) : false}
              onClick={() => onOpen(w)} onFavorite={() => onFav(w.id)} />
          ))}
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { WallpaperDetail, LivePreview });
