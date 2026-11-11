document.addEventListener("DOMContentLoaded", function () {

  // Register form checks
  var reg = document.getElementById("registerForm");
  if (reg) reg.addEventListener("submit", function (e) {
    if (reg.password.value.length < 6) { e.preventDefault(); alert("Password must be at least 6 characters."); return; }
    if (reg.password.value !== reg.confirm.value) { e.preventDefault(); alert("Passwords do not match."); }
  });

  // No past dates when adding an event
  var dateInput = document.getElementById("eventDate");
  if (dateInput) dateInput.min = new Date().toISOString().split("T")[0];

  // Confirm before delete / cancel
  document.querySelectorAll("form[data-confirm]").forEach(function (f) {
    f.addEventListener("submit", function (e) { if (!confirm(f.dataset.confirm)) e.preventDefault(); });
  });

  // Search + category chips on the events page
  var search = document.getElementById("search"), chips = document.getElementById("chips");
  var cards = [].slice.call(document.querySelectorAll(".card[data-category]"));
  var active = "All";

  function apply() {
    var q = search ? search.value.toLowerCase() : "";
    cards.forEach(function (c) {
      var ok = (active === "All" || c.dataset.category === active) && c.textContent.toLowerCase().indexOf(q) > -1;
      c.style.display = ok ? "" : "none";
    });
  }
  if (search) search.addEventListener("input", apply);

  if (chips && cards.length) {
    var cats = ["All"];
    cards.forEach(function (c) { if (cats.indexOf(c.dataset.category) < 0) cats.push(c.dataset.category); });
    cats.forEach(function (name) {
      var b = document.createElement("button");
      b.type = "button"; b.textContent = name;
      b.className = "chip" + (name === "All" ? " on" : "");
      b.addEventListener("click", function () {
        active = name;
        chips.querySelectorAll(".chip").forEach(function (x) { x.classList.toggle("on", x === b); });
        apply();
      });
      chips.appendChild(b);
    });
  }
});
