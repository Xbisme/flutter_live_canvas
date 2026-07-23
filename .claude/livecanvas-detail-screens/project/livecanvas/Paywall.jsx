const { IconButton, Button, PremiumBadge } = window.LiveCanvasDesignSystem_1b7873;

function PerkRow({ label, free, pro }) {
  const mark = (on, color) => on
    ? <i className="ph-fill ph-check-circle" style={{ fontSize: 20, color }} />
    : <i className="ph ph-minus" style={{ fontSize: 18, color: "var(--text-tertiary)" }} />;
  return (
    <div style={{ display: "grid", gridTemplateColumns: "1fr 56px 56px", alignItems: "center", padding: "13px 0", borderBottom: "1px solid var(--border-subtle)" }}>
      <span style={{ fontFamily: "var(--font-body)", fontSize: 14, color: "var(--text-primary)" }}>{label}</span>
      <span style={{ textAlign: "center" }}>{mark(free, "var(--text-secondary)")}</span>
      <span style={{ textAlign: "center" }}>{mark(pro, "var(--iris-400)")}</span>
    </div>
  );
}

function Paywall({ onClose, onBuy }) {
  const [plan, setPlan] = React.useState("year");
  const plans = {
    month: { label: "Hàng tháng", price: "59.000₫", sub: "mỗi tháng" },
    year: { label: "Hàng năm", price: "299.000₫", sub: "mỗi năm · tiết kiệm 58%", badge: "Phổ biến" }
  };
  return (
    <div style={{ position: "absolute", inset: 0, background: "var(--bg-app)", overflowY: "auto" }}>
      {/* aurora hero */}
      <div style={{ position: "relative", padding: "16px 20px 28px", background: "radial-gradient(120% 80% at 50% 0%, rgba(124,92,255,0.35), transparent 70%)" }}>
        <div style={{ display: "flex", justifyContent: "flex-end" }}>
          <IconButton icon="x" variant="solid" onClick={onClose} label="Đóng" />
        </div>
        <div style={{ textAlign: "center", marginTop: 8 }}>
          <div style={{ display: "inline-flex", marginBottom: 16 }}><PremiumBadge label="PREMIUM" /></div>
          <h1 style={{ fontFamily: "var(--font-display)", fontSize: 34, fontWeight: 600, letterSpacing: "-0.02em", lineHeight: 1.08, color: "#fff", margin: "0 auto", maxWidth: 300 }}>
            Mở khoá cả kho hình nền sống động
          </h1>
          <p style={{ fontFamily: "var(--font-body)", fontSize: 15, lineHeight: 1.45, color: "var(--text-secondary)", margin: "10px auto 0", maxWidth: 300 }}>
            Toàn bộ nội dung 4K, tải không giới hạn, không quảng cáo.
          </p>
        </div>
      </div>

      {/* comparison */}
      <div style={{ padding: "0 20px" }}>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 56px 56px", alignItems: "center", paddingBottom: 8 }}>
          <span />
          <span style={{ textAlign: "center", fontFamily: "var(--font-mono)", fontSize: 11, color: "var(--text-tertiary)" }}>FREE</span>
          <span style={{ textAlign: "center", fontFamily: "var(--font-mono)", fontSize: 11, fontWeight: 700, color: "var(--iris-400)" }}>PRO</span>
        </div>
        <PerkRow label="Hình nền miễn phí" free pro />
        <PerkRow label="Bộ sưu tập Premium 4K" free={false} pro />
        <PerkRow label="Tải xuống không giới hạn" free={false} pro />
        <PerkRow label="Không quảng cáo" free={false} pro />
        <PerkRow label="Nội dung mới mỗi tuần" free={false} pro />
      </div>

      {/* plans */}
      <div style={{ padding: "22px 20px 0", display: "flex", flexDirection: "column", gap: 10 }}>
        {Object.entries(plans).map(([k, p]) => {
          const on = k === plan;
          return (
            <button key={k} type="button" onClick={() => setPlan(k)}
              style={{ display: "flex", alignItems: "center", justifyContent: "space-between", textAlign: "left", padding: "14px 16px", borderRadius: "var(--r-md)", cursor: "pointer",
                background: on ? "var(--aurora-soft)" : "var(--bg-raised)", border: on ? "1.5px solid var(--iris-500)" : "1px solid var(--border-subtle)" }}>
              <div>
                <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                  <span style={{ fontFamily: "var(--font-body)", fontSize: 15, fontWeight: 700, color: "var(--text-primary)" }}>{p.label}</span>
                  {p.badge && <span style={{ fontFamily: "var(--font-mono)", fontSize: 10, fontWeight: 700, color: "#fff", background: "var(--aurora)", padding: "2px 7px", borderRadius: "var(--r-pill)" }}>{p.badge}</span>}
                </div>
                <div style={{ fontFamily: "var(--font-body)", fontSize: 12, color: "var(--text-secondary)", marginTop: 2 }}>{p.sub}</div>
              </div>
              <div style={{ fontFamily: "var(--font-display)", fontSize: 22, fontWeight: 600, color: "var(--text-primary)" }}>{p.price}</div>
            </button>
          );
        })}
      </div>

      <div style={{ padding: "18px 20px 8px" }}>
        <Button variant="aurora" icon="sparkle" fullWidth onClick={onBuy}>Bắt đầu dùng Premium</Button>
      </div>
      <div style={{ display: "flex", justifyContent: "center", gap: 20, padding: "6px 20px 28px" }}>
        <button type="button" onClick={onClose} style={{ background: "none", border: "none", cursor: "pointer", fontFamily: "var(--font-body)", fontSize: 13, color: "var(--text-secondary)" }}>Khôi phục giao dịch</button>
        <span style={{ color: "var(--text-tertiary)" }}>·</span>
        <button type="button" style={{ background: "none", border: "none", cursor: "pointer", fontFamily: "var(--font-body)", fontSize: 13, color: "var(--text-secondary)" }}>Điều khoản</button>
      </div>
    </div>
  );
}

Object.assign(window, { Paywall, PerkRow });
