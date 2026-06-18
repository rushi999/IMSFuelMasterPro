/* ============================================================
   IMS FUEL MASTER PRO — Nozzle Animation Controller
   ims-nozzle.js  |  Include in footer.jsp after ims-main.js
   ============================================================
   Triggers:
   1. Fuel Entry form submit  → petrol nozzle filling animation
   2. Master record save      → smaller save animation
   3. Tank refill save        → nozzle animation
   ============================================================ */

(function () {
  'use strict';

  /* ════════════════════════════════════════════════════════
     NOZZLE OVERLAY BUILDER
     Injected into <body> once on first call
  ════════════════════════════════════════════════════════ */
  function ensureNozzleOverlay() {
    if (document.getElementById('nozzleOverlay')) return;

    var html =
      '<div id="nozzleOverlay" class="hidden">' +
      '<div class="nozzle-container">' +
        '<div class="nozzle-title" id="nozzleTitle">PROCESSING</div>' +
        '<svg id="nozzleSvg" width="160" height="240" viewBox="0 0 160 240">' +
          '<defs>' +
            '<linearGradient id="nbg" x1="0%" y1="0%" x2="100%" y2="0%">' +
              '<stop offset="0%" stop-color="#1a2a3a"/>' +
              '<stop offset="50%" stop-color="#3a5070"/>' +
              '<stop offset="100%" stop-color="#1a2a3a"/>' +
            '</linearGradient>' +
            '<linearGradient id="nfg" x1="0%" y1="0%" x2="0%" y2="100%">' +
              '<stop offset="0%" stop-color="#3b9eff" stop-opacity="0.95"/>' +
              '<stop offset="100%" stop-color="#0d47a1" stop-opacity="0.8"/>' +
            '</linearGradient>' +
            '<linearGradient id="nfgP" x1="0%" y1="0%" x2="0%" y2="100%">' +
              '<stop offset="0%" stop-color="#ff8c42" stop-opacity="0.95"/>' +
              '<stop offset="100%" stop-color="#e65100" stop-opacity="0.8"/>' +
            '</linearGradient>' +
            '<clipPath id="ntankClip"><rect x="30" y="120" width="100" height="98" rx="8"/></clipPath>' +
          '</defs>' +

          /* Hose curve */
          '<path d="M 80 8 Q 10 8 10 55 Q 10 95 40 105 L 52 110"' +
          '  stroke="#3a5070" stroke-width="11" fill="none" stroke-linecap="round"/>' +
          '<path d="M 80 8 Q 10 8 10 55 Q 10 95 40 105 L 52 110"' +
          '  stroke="#1a2a3a" stroke-width="7"  fill="none" stroke-linecap="round"/>' +

          /* Nozzle body */
          '<rect x="44" y="100" width="32" height="50" rx="6"' +
          '  fill="url(#nbg)" stroke="#4a6080" stroke-width="1.5"/>' +
          /* Grip */
          '<rect x="46" y="116" width="12" height="24" rx="4"' +
          '  fill="#0f1628" stroke="#3b9eff" stroke-width="1" opacity="0.85"/>' +
          /* Trigger */
          '<path d="M 50 128 L 56 128 L 56 138 L 50 136 Z"' +
          '  fill="#2a4060" stroke="#3b9eff" stroke-width="0.8"/>' +
          /* Spout */
          '<rect x="68" y="108" width="26" height="9" rx="4"' +
          '  fill="#2a3a5a" stroke="#4a6080" stroke-width="1.5"/>' +
          '<rect x="88" y="110" width="16" height="5" rx="2"' +
          '  fill="#1a2a3a"/>' +

          /* Animated fuel stream */
          '<g id="nFuelStream">' +
            '<rect id="nStream" x="96" y="119" width="7" height="10" rx="2"' +
            '  fill="url(#nfg)" opacity="0">' +
              '<animate id="nStreamAnim" attributeName="height" values="0;10;0" dur="0.35s" begin="indefinite" repeatCount="indefinite"/>' +
              '<animate attributeName="opacity" values="0;0.9;0" dur="0.35s" begin="indefinite" repeatCount="indefinite"/>' +
            '</rect>' +
            '<ellipse id="nDrop" cx="99" cy="132" rx="4" ry="2" fill="#3b9eff" opacity="0">' +
              '<animate id="nDropAnim" attributeName="cy" values="130;136;130" dur="0.35s" begin="indefinite" repeatCount="indefinite"/>' +
              '<animate attributeName="opacity" values="0.8;0.1;0.8" dur="0.35s" begin="indefinite" repeatCount="indefinite"/>' +
            '</ellipse>' +
          '</g>' +

          /* Tank body */
          '<rect x="30" y="130" width="100" height="98" rx="8"' +
          '  fill="rgba(10,15,28,0.9)" stroke="#3a5070" stroke-width="2"/>' +

          /* Animated fill */
          '<g clip-path="url(#ntankClip)">' +
            '<rect id="nFill" x="30" y="228" width="100" height="0"' +
            '  fill="url(#nfg)">' +
              '<animate id="nFillAnim" attributeName="y"      from="228" to="130" dur="2.4s" begin="indefinite" fill="freeze"/>' +
              '<animate id="nFillHAnim" attributeName="height" from="0"   to="98"  dur="2.4s" begin="indefinite" fill="freeze"/>' +
            '</rect>' +
            /* Wave on fill surface */
            '<path id="nWave"' +
            '  d="M20,228 C35,222 55,234 75,228 C95,222 115,234 135,228 C155,222 175,234 195,228 V260 H20Z"' +
            '  fill="rgba(59,158,255,0.45)" opacity="0">' +
              '<animate id="nWaveAnim"' +
              '  attributeName="d"' +
              '  values="M20,228 C35,222 55,234 75,228 C95,222 115,234 135,228 V260 H20Z;' +
                       'M20,130 C35,124 55,136 75,130 C95,124 115,136 135,130 V260 H20Z;' +
                       'M20,130 C35,124 55,136 75,130 C95,124 115,136 135,130 V260 H20Z"' +
              '  dur="2.4s" begin="indefinite" fill="freeze"/>' +
              '<animate id="nWaveOpAnim" attributeName="opacity" values="0;0.5;0.45" dur="2.4s" begin="indefinite" fill="freeze"/>' +
              '<animateTransform id="nWaveMoveAnim" attributeName="transform" type="translate"' +
              '  values="0,0;-40,0;-80,0" dur="2.4s" begin="indefinite" fill="freeze"/>' +
            '</path>' +
            /* Bubble 1 */
            '<circle cx="60" cy="200" r="4" fill="rgba(100,180,255,0.3)" opacity="0">' +
              '<animate attributeName="cy"      values="220;150;150" dur="2.4s" begin="indefinite" fill="freeze"/>' +
              '<animate attributeName="opacity" values="0;0.5;0"     dur="2.4s" begin="indefinite" fill="freeze"/>' +
            '</circle>' +
            /* Bubble 2 */
            '<circle cx="95" cy="210" r="3" fill="rgba(100,180,255,0.25)" opacity="0">' +
              '<animate attributeName="cy"      values="225;160;160" dur="2.2s" begin="0.3s;indefinite" fill="freeze"/>' +
              '<animate attributeName="opacity" values="0;0.4;0"     dur="2.2s" begin="0.3s;indefinite" fill="freeze"/>' +
            '</circle>' +
          '</g>' +

          /* Tank outline */
          '<rect x="30" y="130" width="100" height="98" rx="8"' +
          '  fill="none" stroke="#4a6080" stroke-width="1.5"/>' +
          /* Level marks */
          '<line x1="32" y1="163" x2="40" y2="163" stroke="rgba(255,255,255,0.2)" stroke-width="1"/>' +
          '<line x1="32" y1="195" x2="40" y2="195" stroke="rgba(255,255,255,0.2)" stroke-width="1"/>' +
          '<text x="42" y="167" font-size="8" fill="rgba(255,255,255,0.35)" font-family="monospace">66%</text>' +
          '<text x="42" y="199" font-size="8" fill="rgba(255,255,255,0.35)" font-family="monospace">33%</text>' +
          /* Bottom tap */
          '<rect x="72" y="226" width="18" height="8" rx="4"' +
          '  fill="#2a3a5a" stroke="#4a6080" stroke-width="1.5"/>' +
        '</svg>' +

        /* Progress bar */
        '<div class="nozzle-progress-wrap">' +
          '<div id="nozzleProgress"></div>' +
        '</div>' +
        /* Success icon (shown after complete) */
        '<div class="nozzle-success-icon" id="nozzleSuccessIcon">&#10004;</div>' +
        '<div class="nozzle-subtitle" id="nozzleSubtitle">Saving entry...</div>' +
      '</div>' +
      '</div>';

    var div = document.createElement('div');
    div.innerHTML = html;
    document.body.appendChild(div.firstChild);
  }

  /* ════════════════════════════════════════════════════════
     MASTER SAVE OVERLAY BUILDER (smaller, teal themed)
  ════════════════════════════════════════════════════════ */
  function ensureMasterOverlay() {
    if (document.getElementById('masterSaveOverlay')) return;
    var html =
      '<div id="masterSaveOverlay">' +
      '<div class="master-save-box">' +
        '<svg width="80" height="80" viewBox="0 0 80 80">' +
          '<defs>' +
            '<linearGradient id="mg" x1="0" y1="0" x2="0" y2="1">' +
              '<stop offset="0%" stop-color="#00e5c3" stop-opacity="0.9"/>' +
              '<stop offset="100%" stop-color="#00a890" stop-opacity="0.8"/>' +
            '</linearGradient>' +
          '</defs>' +
          /* Database cylinder top */
          '<ellipse cx="40" cy="16" rx="28" ry="8" fill="url(#mg)" opacity="0.9"/>' +
          '<rect x="12" y="16" width="56" height="48" fill="url(#mg)" opacity="0.7"/>' +
          '<ellipse cx="40" cy="64" rx="28" ry="8" fill="url(#mg)" opacity="0.9"/>' +
          /* Shine stripe */
          '<rect x="16" y="18" width="10" height="44" rx="5" fill="rgba(255,255,255,0.12)"/>' +
          /* Animated data lines */
          '<line x1="20" y1="34" x2="60" y2="34" stroke="rgba(255,255,255,0.3)" stroke-width="2">' +
            '<animate attributeName="x2" values="20;60;20" dur="0.8s" repeatCount="indefinite"/>' +
          '</line>' +
          '<line x1="20" y1="44" x2="60" y2="44" stroke="rgba(255,255,255,0.2)" stroke-width="1.5">' +
            '<animate attributeName="x2" values="20;60;20" dur="1.1s" repeatCount="indefinite"/>' +
          '</line>' +
          '<line x1="20" y1="54" x2="60" y2="54" stroke="rgba(255,255,255,0.15)" stroke-width="1">' +
            '<animate attributeName="x2" values="20;60;20" dur="0.9s" repeatCount="indefinite"/>' +
          '</line>' +
          /* Pulse ring */
          '<circle cx="40" cy="40" r="36" fill="none" stroke="#00e5c3" stroke-width="1" opacity="0">' +
            '<animate attributeName="r"       values="20;36;36"  dur="1.2s" repeatCount="indefinite"/>' +
            '<animate attributeName="opacity" values="0.6;0;0"   dur="1.2s" repeatCount="indefinite"/>' +
          '</circle>' +
        '</svg>' +
        '<div class="master-save-title" id="masterSaveTitle">SAVING...</div>' +
        '<div class="master-save-sub"  id="masterSaveSub">Updating master database</div>' +
      '</div>' +
      '</div>';
    var div = document.createElement('div');
    div.innerHTML = html;
    document.body.appendChild(div.firstChild);
  }

  /* ════════════════════════════════════════════════════════
     SHOW NOZZLE ANIMATION
     fuelType: 'DIESEL' | 'PETROL'
  ════════════════════════════════════════════════════════ */
  function showNozzle(title, subtitle, fuelType, onComplete) {
    ensureNozzleOverlay();
    var overlay = document.getElementById('nozzleOverlay');
    if (!overlay) return;

    /* Set fuel colour */
    var isPetrol = (fuelType || '').toUpperCase() === 'PETROL';
    var fillGradId = isPetrol ? 'nfgP' : 'nfg';
    var fillEl = document.getElementById('nFill');
    var waveEl = document.getElementById('nWave');
    if (fillEl) fillEl.setAttribute('fill', 'url(#' + fillGradId + ')');
    var dropEl = document.getElementById('nDrop');
    if (dropEl) dropEl.setAttribute('fill', isPetrol ? '#ff8c42' : '#3b9eff');

    /* Update text */
    document.getElementById('nozzleTitle').textContent    = title    || 'ISSUING FUEL';
    document.getElementById('nozzleSubtitle').textContent = subtitle || 'Saving entry to database...';

    var successIcon = document.getElementById('nozzleSuccessIcon');
    if (successIcon) successIcon.style.display = 'none';

    /* Show overlay */
    overlay.classList.remove('hidden');

    /* Start SVG animations */
    var anims = ['nStreamAnim','nDropAnim','nFillAnim','nFillHAnim',
                 'nWaveAnim','nWaveOpAnim','nWaveMoveAnim'];
    anims.forEach(function(id){
      var el = document.getElementById(id);
      if (el && el.beginElement) {
        try { el.beginElement(); } catch(e) {}
      }
    });

    /* Progress bar */
    var prog = document.getElementById('nozzleProgress');
    if (prog) prog.style.width = '0%';
    var pct = 0;
    var timer = setInterval(function(){
      pct += 1.8;
      if (pct > 100) pct = 100;
      if (prog) prog.style.width = pct.toFixed(0) + '%';
      if (pct >= 100) {
        clearInterval(timer);
        /* Show success */
        if (successIcon) {
          successIcon.style.display = 'block';
          document.getElementById('nozzleSubtitle').textContent = 'Saved successfully!';
          document.getElementById('nozzleSubtitle').style.color = '#00d68f';
        }
        setTimeout(function(){
          overlay.classList.add('hidden');
          if (successIcon) {
            successIcon.style.display = 'none';
            document.getElementById('nozzleSubtitle').style.color = '';
          }
          /* Reset fill animation */
          var f = document.getElementById('nFill');
          if (f) { f.setAttribute('y','228'); f.setAttribute('height','0'); }
          if (typeof onComplete === 'function') onComplete();
        }, 600);
      }
    }, 28);
  }

  /* ════════════════════════════════════════════════════════
     SHOW MASTER SAVE ANIMATION
  ════════════════════════════════════════════════════════ */
  function showMasterSave(title, subtitle, onComplete) {
    ensureMasterOverlay();
    var overlay = document.getElementById('masterSaveOverlay');
    if (!overlay) return;
    document.getElementById('masterSaveTitle').textContent = title    || 'SAVING...';
    document.getElementById('masterSaveSub').textContent   = subtitle || 'Updating master database';
    overlay.classList.add('active');

    var pct = 0;
    var timer = setInterval(function(){
      pct += 3;
      if (pct >= 100) {
        clearInterval(timer);
        setTimeout(function(){
          overlay.classList.remove('active');
          if (typeof onComplete === 'function') onComplete();
        }, 350);
      }
    }, 30);
  }

  /* ════════════════════════════════════════════════════════
     INTERCEPT FUEL ENTRY FORMS
     Attach to #formBARC, #formUNIT, #formLOOSE
  ════════════════════════════════════════════════════════ */
  function interceptFuelForms() {
    var formIds = ['formBARC', 'formUNIT', 'formLOOSE'];
    formIds.forEach(function(fid) {
      var form = document.getElementById(fid);
      if (!form) return;

      form.addEventListener('submit', function(e) {
        /* Validate qty > 0 first */
        var qtyEl = form.querySelector('input[name=qtyIssued]');
        var qty   = qtyEl ? parseFloat(qtyEl.value) : 0;
        if (!qty || qty <= 0) return; /* Let HTML5 validation handle it */

        /* Get fuel type for animation colour */
        var fuelTypeEl = form.querySelector('input[name=fuelType]');
        var fuelType   = fuelTypeEl ? fuelTypeEl.value : 'DIESEL';
        var category   = form.querySelector('input[name=entryCategory]');
        var catVal     = category ? category.value : '';

        var titles = {
          'BARC':  'ISSUING FUEL — BARC VEHICLE',
          'UNIT':  'ISSUING FUEL — OTHER UNIT',
          'LOOSE': 'ISSUING LOOSE SUPPLY'
        };
        var subs = {
          'BARC':  'Recording entry & updating tank level...',
          'UNIT':  'Recording entry & updating tank level...',
          'LOOSE': 'Recording loose supply entry...'
        };

        e.preventDefault();
        var submittedForm = this;

        showNozzle(
          titles[catVal] || 'ISSUING FUEL',
          qty + ' Litres — ' + fuelType + ' — ' + (subs[catVal] || 'Saving...'),
          fuelType,
          function() {
            /* Actually submit after animation */
            submittedForm.submit();
          }
        );
      });
    });
  }

  /* ════════════════════════════════════════════════════════
     INTERCEPT MASTER FORMS
     Attach to unit, vehicle, driver save forms
  ════════════════════════════════════════════════════════ */
  function interceptMasterForms() {
    /* Unit master form */
    var unitForm = document.getElementById('unitForm');
    if (unitForm) {
      unitForm.addEventListener('submit', function(e){
        var name = document.getElementById('fOrgName') ||
                   document.querySelector('input[name=orgName]');
        var val  = name ? name.value.trim() : 'Record';
        if (!val) return;
        e.preventDefault();
        var f = this;
        showMasterSave('SAVING UNIT', 'Updating unit master: ' + val, function(){
          f.submit();
        });
      });
    }

    /* Vehicle form */
    var vForm = document.getElementById('vehicleForm');
    if (vForm) {
      vForm.addEventListener('submit', function(e){
        var vno = document.querySelector('input[name=vehicleNo]');
        var val = vno ? vno.value.trim() : 'Vehicle';
        if (!val) return;
        e.preventDefault();
        var f = this;
        showMasterSave('SAVING VEHICLE', 'Registering: ' + val, function(){
          f.submit();
        });
      });
    }

    /* Driver form */
    var dForm = document.getElementById('driverForm');
    if (dForm) {
      dForm.addEventListener('submit', function(e){
        var dn = document.querySelector('input[name=driverName]');
        var val = dn ? dn.value.trim() : 'Driver';
        if (!val) return;
        e.preventDefault();
        var f = this;
        showMasterSave('SAVING DRIVER', 'Registering driver: ' + val, function(){
          f.submit();
        });
      });
    }

    /* Tank refill form */
    var rForm = document.getElementById('refillForm');
    if (rForm) {
      rForm.addEventListener('submit', function(e){
        var qtyEl = document.querySelector('input[name=refillQty]');
        var qty   = qtyEl ? parseFloat(qtyEl.value) : 0;
        if (!qty || qty <= 0) return;
        var tankSel = document.getElementById('refillTankId');
        var tankName = tankSel && tankSel.selectedIndex > 0
          ? tankSel.options[tankSel.selectedIndex].text.split('—')[0].trim()
          : 'Tank';
        /* Detect fuel type from tank selection */
        var fuelType = 'DIESEL';
        if (tankSel && tankSel.selectedIndex > 0) {
          var opt = tankSel.options[tankSel.selectedIndex];
          var ft  = opt.getAttribute('data-fuel') || opt.text;
          if (ft.indexOf('PETROL') >= 0) fuelType = 'PETROL';
        }
        e.preventDefault();
        var f = this;
        showNozzle(
          'REFILLING TANK',
          qty + ' Litres → ' + tankName,
          fuelType,
          function(){ f.submit(); }
        );
      });
    }
  }

  /* ════════════════════════════════════════════════════════
     INIT on DOM ready
  ════════════════════════════════════════════════════════ */
  function init() {
    ensureNozzleOverlay();
    ensureMasterOverlay();
    interceptFuelForms();
    interceptMasterForms();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  /* Expose publicly */
  window.showNozzleAnimation = showNozzle;
  window.showMasterSave      = showMasterSave;

}());
