const { TopBar, IconButton, FilterChip, WallpaperCard, EmptyState } = window.LiveCanvasDesignSystem_1b7873;

function Search({ favs, onOpen, onFav, onBack }) {
  const [q, setQ] = React.useState("");
  const D = window.LC_DATA;
  const results = q.trim()
    ? window.LC_ALL.filter((w) => (w.title + " " + w.tag + " " + w.author).toLowerCase().includes(q.toLowerCase()))
    : [];
  return (
    <div style={{ height: "100%", overflowY: "auto", background: "var(--bg-app)" }}>
      <div style={{ display: "flex", alignItems: "center", gap: 10, padding: "12px 16px 8px" }}>
        <IconButton icon="arrow-left" variant="ghost" onClick={onBack} label="Quay lại" />
        <div style={{ flex: 1, display: "flex", alignItems: "center", gap: 8, height: 44, padding: "0 14px", background: "var(--bg-raised)", border: "1px solid var(--border-subtle)", borderRadius: "var(--r-pill)" }}>
          <i className="ph ph-magnifying-glass" style={{ fontSize: 18, color: "var(--text-tertiary)" }} />
          <input autoFocus value={q} onChange={(e) => setQ(e.target.value)} placeholder="Tìm hình nền, tag, tác giả…"
            style={{ flex: 1, background: "none", border: "none", outline: "none", color: "var(--text-primary)", fontFamily: "var(--font-body)", fontSize: 15 }} />
          {q && <i className="ph-fill ph-x-circle" onClick={() => setQ("")} style={{ fontSize: 18, color: "var(--text-tertiary)", cursor: "pointer" }} />}
        </div>
      </div>

      {!q.trim() && (
        <div style={{ padding: "16px" }}>
          <div style={{ fontFamily: "var(--font-mono)", fontSize: 11, letterSpacing: "0.08em", textTransform: "uppercase", color: "var(--text-tertiary)", marginBottom: 12 }}>Gợi ý cho bạn</div>
          <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
            {D.suggestions.map((s) => <FilterChip key={s} label={s} icon="magnifying-glass" onClick={() => setQ(s.split(" ")[0])} />)}
          </div>
        </div>
      )}

      {q.trim() && results.length > 0 && (
        <div style={{ padding: "4px 16px 16px" }}>
          <div style={{ fontFamily: "var(--font-mono)", fontSize: 11, color: "var(--text-tertiary)", marginBottom: 12 }}>{results.length} kết quả cho “{q}”</div>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
            {results.map((w) => (
              <WallpaperCard key={w.id} width="100%" preview={w.preview} auraColor={w.aura} title={w.title} author={w.author}
                duration={w.duration} premium={w.premium} favorite={favs.has(w.id)} onClick={() => onOpen(w)} onFavorite={() => onFav(w.id)} />
            ))}
          </div>
        </div>
      )}

      {q.trim() && results.length === 0 && (
        <EmptyState icon="magnifying-glass" title="Không tìm thấy" description={`Không có kết quả cho “${q}”. Thử từ khoá khác hoặc chọn một gợi ý.`} />
      )}
    </div>
  );
}

Object.assign(window, { Search });
