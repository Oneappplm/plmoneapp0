function initializeSectionApplicability() {
  document.querySelectorAll(".section-applicability-container").forEach((container) => {
    const toggle = container.querySelector(".section-applicability-toggle");
    const offForm = container.querySelector(".section-applicability-off-form");

    if (!toggle) return;

    function updateUI() {
      const notApplicable = toggle.checked;

      container.querySelectorAll(".page-applicable").forEach((element) => {
        element.style.setProperty(
          "display",
          notApplicable ? "none" : "",
          "important"
        );
      });

      container.querySelectorAll(".page-not-applicable").forEach((element) => {
        element.style.setProperty(
          "display",
          notApplicable ? "block" : "none",
          "important"
        );
      });
    }

    updateUI();

    if (toggle.dataset.applicabilityInitialized === "true") return;

    toggle.dataset.applicabilityInitialized = "true";

    toggle.addEventListener("change", function () {
      updateUI();

      if (!toggle.checked && offForm) {
        offForm.requestSubmit();
      }
    });
  });
}

document.addEventListener("DOMContentLoaded", initializeSectionApplicability);
document.addEventListener("turbo:load", initializeSectionApplicability);
document.addEventListener("turbolinks:load", initializeSectionApplicability);

if (document.readyState !== "loading") {
  initializeSectionApplicability();
}
