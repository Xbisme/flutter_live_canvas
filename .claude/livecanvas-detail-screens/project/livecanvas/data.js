// LiveCanvas sample data. Gradient `preview` = looping 9:16 video stand-in;
// `aura` = the glow hue the tile + detail chrome adopt.
window.LC_DATA = {
  chips: ["Tất cả", "Neon", "Thiên nhiên", "Không gian", "Trừu tượng", "Tối giản", "Anime"],
  suggestions: ["neon", "aurora", "sakura", "galaxy", "cyber", "sóng biển", "thác", "synth"],
  sections: [
    { title: "Xu hướng tuần này", items: [
      { id: "w1", title: "Neon Rain", author: "studiolux", preview: "linear-gradient(155deg,#FF6F9C,#7C5CFF 55%,#241E33)", aura: "rgba(255,111,156,0.62)", duration: "0:08", res: "4K", size: "12MB", premium: false, tag: "Neon", likes: "24.1K", downloads: "182K", desc: "Cơn mưa neon rơi chậm qua con hẻm Tokyo về đêm, ánh sáng phản chiếu trên mặt đường ướt. Vòng lặp liền mạch 8 giây." },
      { id: "w2", title: "Aurora Drift", author: "nord", preview: "linear-gradient(155deg,#46D5E6,#3FE0A6 55%,#0E3B39)", aura: "rgba(70,213,230,0.55)", duration: "0:12", res: "4K", size: "18MB", premium: true, tag: "Thiên nhiên", likes: "41.7K", downloads: "96K", desc: "Cực quang xanh lục trôi nhẹ trên nền trời Bắc Âu. Chuyển động mềm mại, hoàn hảo cho màn khoá." },
      { id: "w3", title: "Deep Field", author: "cosmos", preview: "linear-gradient(155deg,#7C5CFF,#2A1E4A 60%,#0D0A13)", aura: "rgba(124,92,255,0.6)", duration: "0:10", res: "4K", size: "15MB", premium: false, tag: "Không gian", likes: "18.9K", downloads: "134K", desc: "Trường sao sâu thẳm với những tinh vân tím lặng lẽ xoay. Cảm giác vô tận trên màn hình của bạn." },
      { id: "w4", title: "Liquid Gold", author: "fluidco", preview: "linear-gradient(155deg,#FFC24C,#FF6F9C 60%,#3A1E2E)", aura: "rgba(255,194,76,0.55)", duration: "0:06", res: "2K", size: "8MB", premium: true, tag: "Trừu tượng", likes: "12.3K", downloads: "58K", desc: "Vàng lỏng cuộn trào theo từng nhịp, kết cấu kim loại ấm áp và sang trọng." }
    ]},
    { title: "Neon về đêm", items: [
      { id: "w5", title: "Shibuya 2099", author: "tokyo", preview: "linear-gradient(155deg,#FF6F9C,#46D5E6 65%,#12101A)", aura: "rgba(255,111,156,0.55)", duration: "0:09", res: "4K", size: "14MB", premium: false, tag: "Neon", likes: "33.5K", downloads: "210K", desc: "Ngã tư Shibuya trong tương lai, biển hiệu hologram nhấp nháy không ngừng." },
      { id: "w6", title: "Synth Highway", author: "retro", preview: "linear-gradient(155deg,#7C5CFF,#FF6F9C 70%,#1A1626)", aura: "rgba(124,92,255,0.55)", duration: "0:11", res: "4K", size: "16MB", premium: true, tag: "Neon", likes: "27.8K", downloads: "88K", desc: "Đường cao tốc synthwave vô tận, lưới neon chạy về phía chân trời tím." },
      { id: "w7", title: "Cyber Alley", author: "blade", preview: "linear-gradient(155deg,#46D5E6,#7C5CFF 60%,#0D0A13)", aura: "rgba(70,213,230,0.5)", duration: "0:07", res: "2K", size: "9MB", premium: false, tag: "Neon", likes: "15.2K", downloads: "72K", desc: "Con hẻm cyberpunk ẩm ướt, hơi nước bốc lên dưới ánh đèn xanh lam." },
      { id: "w8", title: "Pink Static", author: "vhs", preview: "linear-gradient(155deg,#FF8FB2,#FF6F9C 55%,#2A1622)", aura: "rgba(255,143,178,0.55)", duration: "0:05", res: "2K", size: "7MB", premium: false, tag: "Neon", likes: "9.4K", downloads: "44K", desc: "Nhiễu tĩnh hồng phong cách VHS, hoài niệm và mềm mại." }
    ]},
    { title: "Thiên nhiên sống động", items: [
      { id: "w9", title: "Rừng mưa", author: "wild", preview: "linear-gradient(155deg,#3FE0A6,#46D5E6 60%,#0E3B39)", aura: "rgba(63,224,166,0.5)", duration: "0:14", res: "4K", size: "22MB", premium: true, tag: "Thiên nhiên", likes: "38.1K", downloads: "76K", desc: "Rừng mưa nhiệt đới, những giọt nước lăn trên lá xanh mướt." },
      { id: "w10", title: "Sakura Fall", author: "kyoto", preview: "linear-gradient(155deg,#FF8FB2,#FFC24C 65%,#2A1E2E)", aura: "rgba(255,143,178,0.5)", duration: "0:10", res: "4K", size: "17MB", premium: false, tag: "Thiên nhiên", likes: "52.6K", downloads: "245K", desc: "Cánh hoa anh đào rơi nhẹ trong nắng chiều Kyoto, dịu dàng và thanh bình." },
      { id: "w11", title: "Sóng biển", author: "pacific", preview: "linear-gradient(155deg,#46D5E6,#7C5CFF 70%,#0D2B33)", aura: "rgba(70,213,230,0.5)", duration: "0:12", res: "4K", size: "19MB", premium: false, tag: "Thiên nhiên", likes: "29.0K", downloads: "160K", desc: "Sóng biển đêm vỗ nhịp nhàng dưới ánh trăng lam." },
      { id: "w12", title: "Thác đêm", author: "mist", preview: "linear-gradient(155deg,#3FE0A6,#7C5CFF 65%,#101A26)", aura: "rgba(63,224,166,0.5)", duration: "0:13", res: "4K", size: "20MB", premium: true, tag: "Thiên nhiên", likes: "21.4K", downloads: "63K", desc: "Thác nước chảy trong màn sương, ánh sáng huyền ảo len qua tán cây." }
    ]}
  ]
};
window.LC_ALL = window.LC_DATA.sections.flatMap(s => s.items);
window.LC_BY_ID = Object.fromEntries(window.LC_ALL.map(w => [w.id, w]));

// Curated collections — the "bộ sưu tập" surface.
window.LC_COLLECTIONS = [
  { id: "c-neon", title: "Neon về đêm", author: "tokyo", tag: "Neon", premium: false,
    cover: "linear-gradient(155deg,#FF6F9C,#7C5CFF 55%,#12101A)", aura: "rgba(255,111,156,0.55)",
    desc: "12 hình nền lấy cảm hứng từ những thành phố không bao giờ ngủ — đèn neon, mưa đêm và ánh sáng phản chiếu.",
    itemIds: ["w5", "w6", "w7", "w8", "w1", "w3"] },
  { id: "c-nature", title: "Thiên nhiên sống động", author: "wild", tag: "Thiên nhiên", premium: true,
    cover: "linear-gradient(155deg,#3FE0A6,#46D5E6 60%,#0E3B39)", aura: "rgba(63,224,166,0.5)",
    desc: "Bộ sưu tập 4K độc quyền: rừng mưa, sóng biển và thác nước chuyển động chân thực đến từng khung hình.",
    itemIds: ["w9", "w11", "w12", "w2", "w10"] },
  { id: "c-space", title: "Ngoài không gian", author: "cosmos", tag: "Không gian", premium: false,
    cover: "linear-gradient(155deg,#7C5CFF,#2A1E4A 60%,#0D0A13)", aura: "rgba(124,92,255,0.6)",
    desc: "Tinh vân, trường sao và những dải ngân hà xoay chậm — vũ trụ ngay trên màn hình khoá của bạn.",
    itemIds: ["w3", "w6", "w2", "w12"] }
];
window.LC_COLL_BY_ID = Object.fromEntries(window.LC_COLLECTIONS.map(c => [c.id, c]));

// Which collection a wallpaper belongs to (first match), for the detail-screen link.
window.LC_COLL_OF = (id) => window.LC_COLLECTIONS.find(c => c.itemIds.includes(id)) || window.LC_COLLECTIONS[0];

// "Related" = same tag, excluding self, padded from the full set.
window.LC_RELATED = (w) => {
  const same = window.LC_ALL.filter(x => x.tag === w.tag && x.id !== w.id);
  const rest = window.LC_ALL.filter(x => x.tag !== w.tag && x.id !== w.id);
  return [...same, ...rest].slice(0, 4);
};

// Pull hex swatches out of a gradient string → the content palette row.
window.LC_PALETTE = (grad) => (grad.match(/#[0-9A-Fa-f]{6}/g) || []).slice(0, 4);
