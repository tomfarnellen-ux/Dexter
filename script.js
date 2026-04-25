// Conveya — basic landing site interactivity.
// Three small things: animate the headline stats when the section scrolls
// in, run the indicative quote calculator, and validate the contact form.

(function () {
  const fmtGBP = (n) =>
    "£" + Math.round(n).toLocaleString("en-GB");

  // --- Stat counters ---------------------------------------------------
  const stats = document.querySelectorAll(".stat .num");
  const animateStat = (el) => {
    const target = parseFloat(el.dataset.count);
    const prefix = el.dataset.prefix || "";
    const suffix = el.dataset.suffix || "";
    const duration = 900;
    const start = performance.now();
    const isFloat = !Number.isInteger(target);
    const tick = (now) => {
      const t = Math.min(1, (now - start) / duration);
      const eased = 1 - Math.pow(1 - t, 3);
      const value = target * eased;
      el.textContent =
        prefix +
        (isFloat ? value.toFixed(1) : Math.round(value).toString()) +
        suffix;
      if (t < 1) requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
  };

  if ("IntersectionObserver" in window && stats.length) {
    const io = new IntersectionObserver(
      (entries) => {
        entries.forEach((e) => {
          if (e.isIntersecting) {
            animateStat(e.target);
            io.unobserve(e.target);
          }
        });
      },
      { threshold: 0.4 }
    );
    stats.forEach((s) => io.observe(s));
  }

  // --- Indicative quote calculator ------------------------------------
  // Banded legal fee from public UK ranges; SDLT uses the standard
  // residential bands with a first-time-buyer carve-out at £425k.
  const legalFor = (price) => {
    if (price <= 250000) return 950;
    if (price <= 500000) return 1250;
    if (price <= 1000000) return 1650;
    return 1650 + Math.round((price - 1000000) / 1000) * 1.5;
  };

  const sdltFor = (price, ftb) => {
    let bands;
    if (ftb && price <= 625000) {
      bands = [
        [425000, 0],
        [625000, 0.05],
      ];
    } else {
      bands = [
        [250000, 0],
        [925000, 0.05],
        [1500000, 0.1],
        [Infinity, 0.12],
      ];
    }
    let owed = 0;
    let prev = 0;
    for (const [cap, rate] of bands) {
      if (price <= prev) break;
      const slice = Math.min(price, cap) - prev;
      if (slice > 0) owed += slice * rate;
      prev = cap;
    }
    return Math.max(0, owed);
  };

  const form = document.getElementById("quoteForm");
  const result = document.getElementById("quoteResult");
  const compute = () => {
    const price = Math.max(0, parseFloat(document.getElementById("price").value) || 0);
    const tenure = document.getElementById("tenure").value;
    const ftb = document.getElementById("ftb").checked;

    const legal = legalFor(price) + (tenure === "leasehold" ? 250 : 0);
    const searches = 350;
    const sdlt = sdltFor(price, ftb);
    const vat = (legal + searches) * 0.2;
    const total = legal + searches + sdlt + vat;

    result.querySelector('[data-k="legal"]').textContent = fmtGBP(legal);
    result.querySelector('[data-k="searches"]').textContent = fmtGBP(searches);
    result.querySelector('[data-k="sdlt"]').textContent = fmtGBP(sdlt);
    result.querySelector('[data-k="vat"]').textContent = fmtGBP(vat);
    result.querySelector('[data-k="total"]').textContent = fmtGBP(total);
    result.hidden = false;
  };

  if (form) {
    form.addEventListener("submit", (e) => {
      e.preventDefault();
      compute();
    });
    form.querySelectorAll("input, select").forEach((el) =>
      el.addEventListener("change", () => {
        if (!result.hidden) compute();
      })
    );
  }

  // --- Contact form (no backend; persists locally so the page is real) -
  const contact = document.getElementById("contactForm");
  const status = document.getElementById("contactStatus");
  if (contact) {
    contact.addEventListener("submit", (e) => {
      e.preventDefault();
      status.className = "status";
      const data = Object.fromEntries(new FormData(contact).entries());
      if (!data.name || !data.email) {
        status.textContent = "Name and email please.";
        status.classList.add("err");
        return;
      }
      if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data.email)) {
        status.textContent = "That email looks off — give it another go.";
        status.classList.add("err");
        return;
      }
      try {
        const all = JSON.parse(localStorage.getItem("conveya:leads") || "[]");
        all.push({ ...data, ts: new Date().toISOString() });
        localStorage.setItem("conveya:leads", JSON.stringify(all));
      } catch (_) {}
      status.textContent = "Thanks — we'll be in touch within the day.";
      status.classList.add("ok");
      contact.reset();
    });
  }
})();
