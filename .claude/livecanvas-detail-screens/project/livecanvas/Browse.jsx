const { TopBar, IconButton, FilterChip, WallpaperCard } = window.LiveCanvasDesignSystem_1b7873;

function ChipRail({ chips, active, onPick }) {
  return (
    <div style={{ display: "flex", gap: 8, overflowX: "auto", padding: "4px 16px 12px", scrollbarWidth: "none" }}>
      {chips.map((c) => (
        <FilterChip key={c} label={c} active={c === active} onClick={() => onPick(c)} />
      ))}
    </div>
  );
}

function SectionGrid({ title, items, favs, onOpen, onFav }) {
  return (
    <section style={{ padding: "0 16px", marginBottom: 26 }}>
      <div style={{ display: "flex", alignItems: "baseline", justifyContent: "space-between", marginBottom: 12 }}>
        <h2 style={{ fontFamily: "var(--font-display)", fontSize: 22, fontWeight: 600, letterSpacing: "-0.02em", color: "var(--text-primary)", margin: 0 }}>{title}</h2>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: 11, color: "var(--text-tertiary)" }}>{items.length}</span>
      </div>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
        {items.map((w) => (
          <WallpaperCard key={w.id} width="100%" preview={w.preview} auraColor={w.aura} title={w.title} author={w.author}
            duration={w.duration} premium={w.premium} favorite={favs.has(w.id)}
            onClick={() => onOpen(w)} onFavorite={() => onFav(w.id)} />
        ))}
      </div>
    </section>
  );
}

function Browse({ favs, onOpen, onFav, onSearch }) {
  const [chip, setChip] = React.useState("Tất cả");
  const D = window.LC_DATA;
  const filtered = (items) => chip === "Tất cả" ? items : items.filter((w) => w.tag === chip);
  const sections = D.sections.map((s) => ({ ...s, items: filtered(s.items) })).filter((s) => s.items.length);
  return (
    <div style={{ height: "100%", overflowY: "auto", background: "var(--bg-app)" }}>
      <TopBar wordmark trailing={<IconButton icon="magnifying-glass" variant="ghost" onClick={onSearch} />} />
      <ChipRail chips={D.chips} active={chip} onPick={setChip} />
      {sections.map((s) => (
        <SectionGrid key={s.title} title={s.title} items={s.items} favs={favs} onOpen={onOpen} onFav={onFav} />
      ))}
      <div style={{ height: 12 }} />
    </div>
  );
}

Object.assign(window, { Browse, ChipRail, SectionGrid });
