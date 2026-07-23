const { IconButton, Button, MetaChip, PremiumBadge, WallpaperCard } = window.LiveCanvasDesignSystem_1b7873;

// Collection detail — a curated set. Cover hero adopts the collection hue, then a grid.
function Collection({ coll, favs, subscribed, onBack, onOpen, onFav, onShare, onPremium }) {
  if (!coll) return null;
  const items = coll.itemIds.map((id) => window.LC_BY_ID[id]).filter(Boolean);
  const locked = coll.premium && !subscribed;

  return (
    <div style={{ position: "absolute", inset: 0, background: "var(--bg-app)", overflowY: "auto" }}>
      {/* floating chrome */}
      <div style={{ position: "absolute", zIndex: 10, top: 0, left: 0, right: 0, display: "flex", justifyContent: "space-between", alignItems: "center", padding: "14px 16px" }}>
        <IconButton icon="arrow-left" variant="glass" onClick={onBack} label="Quay lại" />
        <IconButton icon="share-network" variant="glass" onClick={onShare} label="Chia sẻ" />
      </div>

      {/* cover hero */}
      <div style={{ position: "relative", height: 300, overflow: "hidden" }}>
        <div className="lc-drift" style={{ position: "absolute", inset: "-10%", background: coll.cover, backgroundSize: "180% 180%" }} />
        <div className="lc-blob" style={{ position: "absolute", width: "70%", height: "45%", left: "15%", top: "18%", background: coll.aura, filter: "blur(70px)", borderRadius: "50%" }} />
        <div style={{ position: "absolute", inset: 0, background: "linear-gradient(to top, var(--bg-app) 2%, rgba(9,7,14,0.2) 45%, rgba(9,7,14,0.35))" }} />
        <div style={{ position: "absolute", left: 20, right: 20, bottom: 18 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 10 }}>
            {coll.premium && <PremiumBadge />}
            <span style={{ fontFamily: "var(--font-mono)", fontSize: 10, color: "rgba(246,243,251,0.7)", letterSpacing: "0.1em" }}>BỘ SƯU TẬP</span>
          </div>
          <h1 style={{ fontFamily: "var(--font-display)", fontSize: 34, fontWeight: 600, letterSpacing: "-0.02em", color: "#fff", margin: 0, lineHeight: 1.02 }}>{coll.title}</h1>
        </div>
      </div>

      {/* meta + desc + actions */}
      <div style={{ padding: "18px 20px 8px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 14 }}>
          <div style={{ width: 34, height: 34, borderRadius: "var(--r-pill)", background: "var(--aurora)", display: "flex", alignItems: "center", justifyContent: "center" }}><i className="ph-fill ph-user" style={{ fontSize: 16, color: "#fff" }} /></div>
          <span style={{ fontFamily: "var(--font-body)", fontSize: 14, fontWeight: 700, color: "var(--text-primary)" }}>@{coll.author}</span>
          <span style={{ color: "var(--text-tertiary)" }}>·</span>
          <span style={{ fontFamily: "var(--font-mono)", fontSize: 12, color: "var(--text-tertiary)" }}>{items.length} hình nền</span>
        </div>
        <p style={{ fontFamily: "var(--font-body)", fontSize: 14, lineHeight: 1.6, color: "var(--text-secondary)", margin: "0 0 18px", textWrap: "pretty" }}>{coll.desc}</p>

        {locked ? (
          <Button variant="aurora" icon="sparkle" fullWidth onClick={onPremium}>Mở khoá bộ sưu tập</Button>
        ) : (
          <div style={{ display: "flex", gap: 10 }}>
            <Button variant="secondary" icon="share-network" onClick={onShare}>Chia sẻ</Button>
            <Button variant="primary" icon="download-simple" fullWidth>Tải tất cả</Button>
          </div>
        )}
      </div>

      {/* grid */}
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12, padding: "20px 16px 28px" }}>
        {items.map((w) => (
          <WallpaperCard key={w.id} width="100%" preview={w.preview} auraColor={w.aura} title={w.title} author={"@" + w.author}
            duration={w.duration} premium={w.premium} favorite={favs ? favs.has(w.id) : false}
            onClick={() => onOpen(w)} onFavorite={() => onFav(w.id)} />
        ))}
      </div>
    </div>
  );
}

Object.assign(window, { Collection });

// Collections tab — full-bleed cover cards listing every curated set.
function CollectionsBrowse({ onOpen }) {
  const { TopBar } = window.LiveCanvasDesignSystem_1b7873;
  const colls = window.LC_COLLECTIONS;
  return (
    <div style={{ height: "100%", overflowY: "auto", background: "var(--bg-app)" }}>
      <TopBar title="Bộ sưu tập" trailing={<span style={{ fontFamily: "var(--font-mono)", fontSize: 12, color: "var(--text-tertiary)" }}>{colls.length}</span>} />
      <div style={{ display: "flex", flexDirection: "column", gap: 16, padding: "6px 16px 16px" }}>
        {colls.map((c) => (
          <button key={c.id} type="button" onClick={() => onOpen(c)} className="lc-coll-card"
            style={{ position: "relative", height: 168, borderRadius: "var(--r-lg)", overflow: "hidden", cursor: "pointer", border: "1px solid var(--border-subtle)", padding: 0, boxShadow: `0 12px 30px ${c.aura}` }}>
            <div className="lc-drift" style={{ position: "absolute", inset: "-10%", background: c.cover, backgroundSize: "180% 180%" }} />
            <div style={{ position: "absolute", inset: 0, background: "linear-gradient(to top, rgba(9,7,14,0.85), rgba(9,7,14,0.1) 55%)" }} />
            <div style={{ position: "absolute", top: 12, right: 12 }}>
              {c.premium && <window.LiveCanvasDesignSystem_1b7873.PremiumBadge />}
            </div>
            <div style={{ position: "absolute", left: 16, right: 16, bottom: 14, textAlign: "left" }}>
              <div style={{ fontFamily: "var(--font-display)", fontSize: 24, fontWeight: 600, letterSpacing: "-0.02em", color: "#fff" }}>{c.title}</div>
              <div style={{ display: "flex", alignItems: "center", gap: 8, marginTop: 4 }}>
                <span style={{ fontFamily: "var(--font-body)", fontSize: 13, color: "rgba(246,243,251,0.8)" }}>@{c.author}</span>
                <span style={{ color: "rgba(246,243,251,0.5)" }}>·</span>
                <span style={{ fontFamily: "var(--font-mono)", fontSize: 12, color: "rgba(246,243,251,0.7)" }}>{c.itemIds.length} hình nền</span>
              </div>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}

Object.assign(window, { Collection, CollectionsBrowse });
