/** Scrolls the page to the top. On phones the page scrolls inside #app-scroll
 * (so the bottom menu stays put); on larger screens the window scrolls. */
export function scrollPageToTop() {
  window.scrollTo({ top: 0 });
  document.getElementById("app-scroll")?.scrollTo({ top: 0 });
}
