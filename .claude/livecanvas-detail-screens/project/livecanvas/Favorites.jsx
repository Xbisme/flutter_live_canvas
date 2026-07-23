const { TopBar, WallpaperCard, EmptyState } = window.LiveCanvasDesignSystem_1b7873;

function Favorites({ favs, onOpen, onFav, onBrowse }) {
  const items = window.LC_ALL.filter((w) => favs.has(w.id));
  return (
    <div style={{ height: "100%", overflowY: "auto", background: "var(--bg-app)" }}>
      <TopBar title="Yêu thích" trailing={items.length ? <span style={{ fontFamily: "var(--font-mono)", fontSize: 12, color: "var(--text-tertiary)" }}>{items.length}</span> : null} />
      {items.length === 0 ? (
        <div style={{ paddingTop: 40 }}>
          <EmptyState icon="heart" title="Chưa có gì ở đây" description="Chạm vào ♥ trên bất kỳ hình nền nào để lưu lại đây." actionLabel="Khám phá hình nền" onAction={onBrowse} />
        </div>
      ) : (
        <div style={{ padding: "4px 16px 16px" }}>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
            {items.map((w) => (
              <WallpaperCard key={w.id} width="100%" preview={w.preview} auraColor={w.aura} title={w.title} author={w.author}
                duration={w.duration} premium={w.premium} favorite onClick={() => onOpen(w)} onFavorite={() => onFav(w.id)} />
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

Object.assign(window, { Favorites });
