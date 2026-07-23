const { IconButton, Button } = window.LiveCanvasDesignSystem_1b7873;

// Bottom-sheet shell with a slide-up, dim backdrop, and grab handle.
function Sheet({ onClose, children, pad = "10px 20px 26px" }) {
  return (
    <div style={{ position: "absolute", inset: 0, background: "rgba(9,7,14,0.6)", backdropFilter: "blur(4px)", WebkitBackdropFilter: "blur(4px)", display: "flex", alignItems: "flex-end", zIndex: 30 }} onClick={onClose}>
      <div className="lc-sheet" onClick={(e) => e.stopPropagation()}
        style={{ width: "100%", background: "var(--bg-surface)", borderTopLeftRadius: "var(--r-xl)", borderTopRightRadius: "var(--r-xl)", boxShadow: "var(--shadow-sheet)", padding: pad, maxHeight: "88%", overflowY: "auto" }}>
        <div style={{ width: 40, height: 4, borderRadius: 2, background: "var(--border-strong)", margin: "0 auto 16px" }} />
        {children}
      </div>
    </div>
  );
}

// Share sheet — target circles + copy-link row. No real network; taps flash a toast.
function ShareSheet({ wall, onClose, onToast }) {
  const targets = [
    { icon: "link-simple", label: "Sao chép", color: "var(--iris-500)" },
    { icon: "chat-circle", label: "Tin nhắn", color: "var(--aqua-500)" },
    { icon: "instagram-logo", label: "Stories", color: "var(--blush-500)" },
    { icon: "telegram-logo", label: "Telegram", color: "#46A5E6" },
    { icon: "dots-three", label: "Khác", color: "var(--onyx-3)" }
  ];
  const hit = (t) => { onToast(t.label === "Sao chép" ? "Đã sao chép liên kết" : "Đã chia sẻ qua " + t.label); onClose(); };
  return (
    <Sheet onClose={onClose}>
      <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 18 }}>
        <div style={{ width: 44, height: 58, borderRadius: "var(--r-sm)", background: wall.preview, backgroundSize: "cover", flexShrink: 0 }} />
        <div style={{ minWidth: 0 }}>
          <div style={{ fontFamily: "var(--font-display)", fontSize: 17, fontWeight: 600, color: "var(--text-primary)" }}>{wall.title}</div>
          <div style={{ fontFamily: "var(--font-body)", fontSize: 12, color: "var(--text-secondary)" }}>livecanvas.app/w/{wall.id}</div>
        </div>
      </div>
      <div style={{ display: "flex", justifyContent: "space-between", gap: 6 }}>
        {targets.map((t) => (
          <button key={t.label} type="button" onClick={() => hit(t)} style={{ flex: 1, background: "none", border: "none", cursor: "pointer", display: "flex", flexDirection: "column", alignItems: "center", gap: 8 }}>
            <span style={{ width: 52, height: 52, borderRadius: "var(--r-pill)", background: t.color, display: "flex", alignItems: "center", justifyContent: "center" }}><i className={`ph-fill ph-${t.icon}`} style={{ fontSize: 22, color: "#fff" }} /></span>
            <span style={{ fontFamily: "var(--font-body)", fontSize: 11, color: "var(--text-secondary)" }}>{t.label}</span>
          </button>
        ))}
      </div>
    </Sheet>
  );
}

// "More" sheet — the ⋮ menu: report opens a confirm step in place.
function MoreSheet({ wall, favorite, onClose, onFav, onShare, onCollection, onToast }) {
  const [report, setReport] = React.useState(false);
  const Row = ({ icon, label, danger, onClick }) => (
    <button type="button" onClick={onClick} style={{ display: "flex", alignItems: "center", gap: 14, width: "100%", textAlign: "left", background: "none", border: "none", cursor: "pointer", padding: "15px 0", borderBottom: "1px solid var(--border-subtle)" }}>
      <i className={`ph ph-${icon}`} style={{ fontSize: 22, color: danger ? "var(--danger)" : "var(--text-secondary)" }} />
      <span style={{ flex: 1, fontFamily: "var(--font-body)", fontSize: 15, color: danger ? "var(--danger)" : "var(--text-primary)" }}>{label}</span>
    </button>
  );

  if (report) {
    const reasons = ["Nội dung không phù hợp", "Vi phạm bản quyền", "Chất lượng kém", "Spam hoặc gây hiểu lầm"];
    return (
      <Sheet onClose={onClose}>
        <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 6 }}>
          <IconButton icon="arrow-left" variant="ghost" size={36} onClick={() => setReport(false)} label="Quay lại" />
          <h2 style={{ fontFamily: "var(--font-display)", fontSize: 20, fontWeight: 600, color: "var(--text-primary)", margin: 0 }}>Báo cáo nội dung</h2>
        </div>
        <p style={{ fontFamily: "var(--font-body)", fontSize: 13, color: "var(--text-tertiary)", margin: "0 0 6px 46px" }}>Chọn lý do — đội ngũ LiveCanvas sẽ xem xét.</p>
        <div style={{ marginTop: 8 }}>
          {reasons.map((r) => (
            <Row key={r} icon="flag" label={r} onClick={() => { onToast("Đã gửi báo cáo. Cảm ơn bạn."); onClose(); }} />
          ))}
        </div>
      </Sheet>
    );
  }

  return (
    <Sheet onClose={onClose}>
      <Row icon="heart" label={favorite ? "Bỏ khỏi yêu thích" : "Thêm vào yêu thích"} onClick={() => { onFav(); onClose(); }} />
      <Row icon="share-network" label="Chia sẻ hình nền" onClick={() => { onClose(); onShare(); }} />
      <Row icon="squares-four" label="Xem bộ sưu tập" onClick={() => { onClose(); onCollection(); }} />
      <Row icon="user-minus" label="Ẩn tác giả này" onClick={() => { onToast("Đã ẩn @" + wall.author); onClose(); }} />
      <Row icon="flag" label="Báo cáo nội dung" danger onClick={() => setReport(true)} />
    </Sheet>
  );
}

// Transient toast pinned above the bottom edge.
function Toast({ text }) {
  if (!text) return null;
  return (
    <div style={{ position: "absolute", left: 0, right: 0, bottom: 34, display: "flex", justifyContent: "center", zIndex: 40, pointerEvents: "none" }}>
      <div className="lc-toast" style={{ display: "inline-flex", alignItems: "center", gap: 8, maxWidth: "80%", padding: "12px 18px", borderRadius: "var(--r-pill)", background: "var(--onyx-3)", border: "1px solid var(--border-strong)", boxShadow: "var(--shadow-3)" }}>
        <i className="ph-fill ph-check-circle" style={{ fontSize: 18, color: "var(--success)" }} />
        <span style={{ fontFamily: "var(--font-body)", fontSize: 14, color: "var(--text-primary)" }}>{text}</span>
      </div>
    </div>
  );
}

Object.assign(window, { Sheet, ShareSheet, MoreSheet, Toast });
