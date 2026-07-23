const { Button, IconButton } = window.LiveCanvasDesignSystem_1b7873;

// Set-wallpaper flow. iOS and Android differ at the OS level, so the sheet tells the
// user which path they're on without making it feel like a limitation.
function SetWallpaper({ wall, onClose }) {
  const [os, setOs] = React.useState("android");
  const [done, setDone] = React.useState(false);

  const Seg = ({ id, icon, label }) => (
    <button type="button" onClick={() => { setOs(id); setDone(false); }}
      style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center", gap: 6, height: 38, borderRadius: "var(--r-sm)", cursor: "pointer", border: "none",
        background: os === id ? "var(--bg-app)" : "transparent", color: os === id ? "var(--text-primary)" : "var(--text-tertiary)",
        fontFamily: "var(--font-body)", fontSize: 14, fontWeight: 700 }}>
      <i className={`ph ph-${icon}`} style={{ fontSize: 18 }} />{label}
    </button>
  );

  const Step = ({ n, children }) => (
    <div style={{ display: "flex", gap: 12, alignItems: "flex-start", padding: "10px 0" }}>
      <span style={{ flexShrink: 0, width: 26, height: 26, borderRadius: "var(--r-pill)", background: "var(--aurora-soft)", border: "1px solid var(--border-subtle)", display: "flex", alignItems: "center", justifyContent: "center", fontFamily: "var(--font-mono)", fontSize: 12, fontWeight: 700, color: "var(--iris-400)" }}>{n}</span>
      <span style={{ fontFamily: "var(--font-body)", fontSize: 14, lineHeight: 1.45, color: "var(--text-secondary)", paddingTop: 2 }}>{children}</span>
    </div>
  );

  return (
    <div style={{ position: "absolute", inset: 0, background: "rgba(9,7,14,0.6)", backdropFilter: "blur(4px)", display: "flex", alignItems: "flex-end" }} onClick={onClose}>
      <div onClick={(e) => e.stopPropagation()}
        style={{ width: "100%", background: "var(--bg-surface)", borderTopLeftRadius: "var(--r-xl)", borderTopRightRadius: "var(--r-xl)", boxShadow: "var(--shadow-sheet)", padding: "10px 20px 24px", maxHeight: "84%", overflowY: "auto" }}>
        <div style={{ width: 40, height: 4, borderRadius: 2, background: "var(--border-strong)", margin: "0 auto 16px" }} />

        {done ? (
          <div style={{ textAlign: "center", padding: "16px 0 8px" }}>
            <i className="ph-fill ph-check-circle" style={{ fontSize: 56, color: "var(--success)" }} />
            <h2 style={{ fontFamily: "var(--font-display)", fontSize: 24, fontWeight: 600, color: "var(--text-primary)", margin: "12px 0 4px" }}>Đã tải xuống</h2>
            <p style={{ fontFamily: "var(--font-body)", fontSize: 14, color: "var(--text-secondary)", margin: "0 auto 20px", maxWidth: 260 }}>
              {os === "android" ? "Chạm tiếp tục để đặt “" + wall.title + "” làm hình nền động ngay bây giờ." : "Làm theo các bước bên dưới để đặt qua Shortcuts."}
            </p>
            {os === "android" ? (
              <Button variant="primary" icon="paint-brush-broad" fullWidth onClick={onClose}>Đặt làm hình nền</Button>
            ) : (
              <div style={{ textAlign: "left" }}>
                <Step n="1">Mở ứng dụng <b style={{ color: "var(--text-primary)" }}>Phím tắt</b> (Shortcuts) của iOS.</Step>
                <Step n="2">Tạo phím tắt <b style={{ color: "var(--text-primary)" }}>Đặt hình nền</b> → chọn video vừa lưu.</Step>
                <Step n="3">Chạy phím tắt vào giờ bạn muốn — hình nền sẽ chuyển động trên màn khoá.</Step>
                <div style={{ marginTop: 14 }}><Button variant="secondary" icon="arrow-square-out" fullWidth onClick={onClose}>Mở Shortcuts</Button></div>
              </div>
            )}
          </div>
        ) : (
          <div>
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 14 }}>
              <h2 style={{ fontFamily: "var(--font-display)", fontSize: 22, fontWeight: 600, color: "var(--text-primary)", margin: 0 }}>Đặt làm hình nền</h2>
              <IconButton icon="x" variant="ghost" onClick={onClose} />
            </div>

            {/* OS segmented control */}
            <div style={{ display: "flex", gap: 4, padding: 4, background: "var(--bg-raised)", borderRadius: "var(--r-md)", border: "1px solid var(--border-subtle)", marginBottom: 8 }}>
              <Seg id="android" icon="android-logo" label="Android" />
              <Seg id="ios" icon="apple-logo" label="iPhone" />
            </div>

            <p style={{ fontFamily: "var(--font-body)", fontSize: 13, lineHeight: 1.45, color: "var(--text-tertiary)", margin: "0 0 8px" }}>
              {os === "android"
                ? "Trên Android, LiveCanvas đặt hình nền động trực tiếp — chỉ một chạm."
                : "iOS không cho app đặt video làm hình nền trực tiếp. LiveCanvas lưu video rồi hướng dẫn bạn đặt qua Shortcuts (một lần thiết lập)."}
            </p>

            <div style={{ margin: "12px 0" }}>
              <Button variant="primary" icon="download-simple" fullWidth onClick={() => setDone(true)}>
                {os === "android" ? "Tải & đặt hình nền" : "Lưu video vào Ảnh"}
              </Button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

Object.assign(window, { SetWallpaper });
