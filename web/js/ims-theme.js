/* ============================================================
   IMS FUEL MASTER PRO — Theme Toggle (ims-theme.js) v3
   Changes: Toggle button includes text label
   ============================================================ */
(function () {
  'use strict';

  var THEME_KEY = 'ims_theme';
  var LIGHT_CLS = 'ims-light';

  function applySavedTheme() {
    try {
      if (localStorage.getItem(THEME_KEY) === 'light') {
        document.body.classList.add(LIGHT_CLS);
      }
    } catch (e) {}
  }

  function isLight() {
    return document.body.classList.contains(LIGHT_CLS);
  }

  function toggleTheme() {
    if (isLight()) {
      document.body.classList.remove(LIGHT_CLS);
      try { localStorage.setItem(THEME_KEY, 'dark'); } catch (e) {}
    } else {
      document.body.classList.add(LIGHT_CLS);
      try { localStorage.setItem(THEME_KEY, 'light'); } catch (e) {}
    }
    updateAllToggleButtons();
  }

  function getBtnHTML() {
    return isLight()
      ? '<i class="fa fa-moon-o ims-theme-icon"></i><span class="ims-theme-label">Switch to Dark Mode</span>'
      : '<i class="fa fa-sun-o ims-theme-icon"></i><span class="ims-theme-label">Switch to Light Mode</span>';
  }

  function updateAllToggleButtons() {
    var btns = document.querySelectorAll('.ims-theme-btn');
    for (var i = 0; i < btns.length; i++) {
      btns[i].innerHTML = getBtnHTML();
      btns[i].title = isLight() ? 'Switch to Dark Mode' : 'Switch to Light Mode';
    }
  }

  function makeToggleBtn() {
    var btn       = document.createElement('a');
    btn.href      = '#';
    btn.className = 'ims-theme-btn';
    btn.innerHTML = getBtnHTML();
    btn.title     = isLight() ? 'Switch to Dark Mode' : 'Switch to Light Mode';
    btn.onclick   = function (e) {
      e.preventDefault();
      e.stopPropagation();
      toggleTheme();
      return false;
    };
    return btn;
  }

  /* ── Inject into Bootstrap navbar right ── */
  function injectNavbarButton() {
    var navRight = document.querySelector('ul.ims-nav-right');
    if (!navRight) navRight = document.querySelector('.navbar-right');
    if (!navRight) return;

    var li = document.createElement('li');
    li.style.cssText = 'display:flex!important;align-items:center!important;padding:0 6px!important;';
    var btn = makeToggleBtn();
    li.appendChild(btn);

    var children = navRight.children;
    if (children && children.length > 0) {
      var lastChild = children[children.length - 1];
      try {
        navRight.insertBefore(li, lastChild);
      } catch (e) {
        navRight.appendChild(li);
      }
    } else {
      navRight.appendChild(li);
    }
  }

  function onReady() {
    applySavedTheme();
    injectNavbarButton();
    updateAllToggleButtons();
  }

  applySavedTheme();

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', onReady);
  } else {
    onReady();
  }

  window.imsToggleTheme = toggleTheme;

}());
