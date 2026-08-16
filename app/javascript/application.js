// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

const HISTORY_ALERT_KEY = "outcome-canvas:history-alert"

function renderStoredHistoryAlert() {
  const message = sessionStorage.getItem(HISTORY_ALERT_KEY)
  const main = document.querySelector("#main-content")

  if (!message || !main) return

  sessionStorage.removeItem(HISTORY_ALERT_KEY)

  const alert = document.createElement("div")
  alert.className = "flash flash--alert"
  alert.setAttribute("role", "alert")
  alert.textContent = message
  main.prepend(alert)
}

async function checkRestoredResource(event) {
  renderStoredHistoryAlert()

  const navigation = performance.getEntriesByType("navigation")[0]
  const restoredFromHistory = event.persisted || navigation?.type === "back_forward"
  const check = document.querySelector("meta[name='history-resource-check']")

  if (!restoredFromHistory || !check) return

  const fallback = document.querySelector("meta[name='history-resource-fallback']")?.content
  const message = document.querySelector("meta[name='history-resource-alert']")?.content

  if (!fallback || !message) return

  const response = await fetch(window.location.href, {
    method: "HEAD",
    cache: "no-store",
    credentials: "same-origin",
    headers: { "X-History-Resource-Check": "true" }
  })

  if (response.status !== 404) return

  sessionStorage.setItem(HISTORY_ALERT_KEY, message)
  window.location.replace(fallback)
}

document.addEventListener("turbo:load", renderStoredHistoryAlert)
window.addEventListener("pageshow", checkRestoredResource)
