const transactions = [
  { title: "Groceries", category: "Food · Today", amount: 250000, type: "expense", icon: "🛒" },
  { title: "Monthly Salary", category: "Salary · Yesterday", amount: 5000000, type: "income", icon: "💼" },
  { title: "Transport", category: "Transport · 8 Nov 2026", amount: 75000, type: "expense", icon: "🚌" },
  { title: "Freelance Project", category: "Other · 7 Nov 2026", amount: 2500000, type: "income", icon: "💻" },
  { title: "Coffee", category: "Food · 6 Nov 2026", amount: 45000, type: "expense", icon: "☕" }
];

const rupiah = value => new Intl.NumberFormat("id-ID", {
  style: "currency", currency: "IDR", maximumFractionDigits: 0
}).format(value);

function renderTransactions() {
  const list = document.getElementById("transaction-list");
  list.innerHTML = transactions.slice(0, 5).map(item => `
    <div class="transaction">
      <div class="transaction-icon ${item.type}">${item.icon}</div>
      <div class="transaction-info">
        <strong>${escapeHTML(item.title)}</strong>
        <small>${escapeHTML(item.category)}</small>
      </div>
      <div class="transaction-amount ${item.type}">
        ${item.type === "income" ? "+" : "−"}${rupiah(item.amount)}
      </div>
    </div>
  `).join("");
}

function escapeHTML(value) {
  return String(value).replace(/[&<>"']/g, char => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#039;"
  })[char]);
}

function updateSummary() {
  const income = transactions.filter(t => t.type === "income").reduce((sum, t) => sum + t.amount, 0);
  const expense = transactions.filter(t => t.type === "expense").reduce((sum, t) => sum + t.amount, 0);
  document.getElementById("income").textContent = rupiah(income);
  document.getElementById("expense").textContent = rupiah(expense);
  document.getElementById("balance").textContent = rupiah(income - expense);
}

const dialog = document.getElementById("transaction-dialog");
const form = document.getElementById("transaction-form");

document.getElementById("today-label").textContent =
  new Intl.DateTimeFormat("en-US", { weekday: "long", day: "numeric", month: "long", year: "numeric" }).format(new Date()).toUpperCase();

document.getElementById("add-transaction").addEventListener("click", () => dialog.showModal());

document.querySelectorAll(".quick-action").forEach(button => {
  button.addEventListener("click", () => {
    form.elements.type.value = button.dataset.type;
    dialog.showModal();
  });
});

form.addEventListener("submit", event => {
  event.preventDefault();
  const data = new FormData(form);
  const amount = Number(data.get("amount"));
  const title = String(data.get("title")).trim();
  if (!title || !Number.isFinite(amount) || amount <= 0) return;

  const category = String(data.get("category"));
  const icons = { Food: "🍽️", Transport: "🚌", Shopping: "🛍️", Salary: "💼", Entertainment: "🎬", Other: "💳" };
  transactions.unshift({
    title,
    category: `${category} · Just now`,
    amount,
    type: String(data.get("type")),
    icon: icons[category] || "💳"
  });

  renderTransactions();
  updateSummary();
  form.reset();
  dialog.close();
});

renderTransactions();
updateSummary();
