// Fills in the parts of the site that depend on today's date or on the course
// data in course.js: This week, the tutorial and reading sidebars, and quizzes.
(function () {
  var C = window.COURSE;
  if (!C) return;

  function el(tag, attrs, html) {
    var e = document.createElement(tag);
    for (var k in attrs || {}) e.setAttribute(k, attrs[k]);
    if (html != null) e.innerHTML = html;
    return e;
  }
  function esc(s) {
    return String(s == null ? '' : s).replace(/[&<>"]/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c];
    });
  }
  function iso(d) {
    return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
  }
  function parse(s) { var p = s.split('-'); return new Date(+p[0], +p[1] - 1, +p[2]); }
  function addDays(d, n) { var x = new Date(d); x.setDate(x.getDate() + n); return x; }
  var MON = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  var DAY = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  function label(d) { return DAY[d.getDay()] + ' ' + MON[d.getMonth()] + ' ' + d.getDate(); }

  // Today in Chapel Hill, so the week flips at the same moment for everyone.
  var today = (function () {
    var q = new URLSearchParams(location.search).get('today');
    if (q) return parse(q);
    try {
      return parse(new Intl.DateTimeFormat('en-CA', { timeZone: 'America/New_York' }).format(new Date()));
    } catch (e) { var n = new Date(); return new Date(n.getFullYear(), n.getMonth(), n.getDate()); }
  })();
  var todayIso = iso(today);

  var rows = C.rows;
  function rowFor(dIso) {
    for (var i = 0; i < rows.length; i++) {
      var r = rows[i];
      if (r.date === dIso) return r;
      if (r.end && r.date <= dIso && dIso <= r.end) return r;
    }
    return null;
  }
  var caseNo = {};
  C.cases.forEach(function (c) { caseNo[c.date] = c.n; });

  // Slides are linked once their class day has arrived.
  document.querySelectorAll('a.slides-link[data-date]').forEach(function (a) {
    if (a.getAttribute('data-date') > todayIso) {
      var box = a.parentNode;
      a.remove();
      if (box && box.classList.contains('row-links') && !box.children.length) box.remove();
    }
  });
  document.querySelectorAll('table.schedule tr[data-date="' + todayIso + '"]').forEach(function (tr) { tr.classList.add('today'); });


  // Everything a student needs for the week, grouped: readings and quizzes,
  // tutorials, homework, case studies and slides. Links only.
  function hwLink(h) {
    var t = 'Homework ' + h.n + ': ' + esc(h.title);
    return '<a href="' + esc(h.href || 'homework.html') + '">' + t + '</a>';
  }
  function weekList(wrows, monIso, friIso) {
    var groups = [];
    function item(when, body) { return '<li><span class="wl-when">' + esc(when) + '</span><span class="wl-what">' + body + '</span></li>'; }

    var read = [];
    wrows.forEach(function (r) {
      (r.readings || []).forEach(function (it) {
        var t = esc(it.title) + (it.section ? ', ' + esc(it.section) : '');
        var body = it.href ? '<a href="' + esc(it.href) + '">' + t + '</a>'
          : !it.slug ? t : '<a href="readings.html">' + t + '</a>' + (it.soon ? ' <span class="muted">(coming soon)</span>' : '');
        if (it.slug && it.href && C.quizzes[it.slug]) body += '<a href="' + esc(it.href) + '#reading-quiz">Reading quiz</a>';
        read.push(item(r.label, body));
      });
    });
    if (read.length) groups.push(['Read Before Class', read]);

    var tut = [];
    wrows.forEach(function (r) {
      if (r.tutorial) tut.push(item(r.label, r.tutorial.href ? '<a href="' + r.tutorial.href + '">' + esc(r.tutorial.title) + '</a>'
        : '<a href="tutorials.html">' + esc(r.tutorial.title) + '</a> <span class="muted">(coming soon)</span>'));
    });
    if (tut.length) groups.push(['Tutorials', tut]);

    var hw = [], seen = {};
    rows.forEach(function (r) {
      var m = /^HW (\d+)/.exec(r.due || '');
      if (!m || !r.date || r.date < monIso || r.date > friIso) return;
      var h = (C.homeworks || []).filter(function (x) { return x.n === m[1]; })[0];
      if (h && !seen[h.n]) { seen[h.n] = 1; hw.push(item('Due ' + r.label, hwLink(h))); }
    });
    if (!hw.length) {
      var nxt = rows.filter(function (r) { return /^HW \d+/.test(r.due || '') && r.date > friIso; })[0];
      if (nxt) {
        var h2 = (C.homeworks || []).filter(function (x) { return x.n === /^HW (\d+)/.exec(nxt.due)[1]; })[0];
        if (h2) hw.push(item('Due ' + nxt.label, hwLink(h2)));
      }
    }
    if (hw.length) groups.push(['Homework', hw]);

    var cs = [];
    wrows.forEach(function (r) {
      if (r.kind === 'prep' || r.kind === 'case') {
        var n = r.kind === 'case' ? caseNo[r.date] : (C.cases.filter(function (c) { return c.date > r.date; })[0] || {}).n;
        if (n) cs.push(item(r.label, '<a href="case_studies.html#case-study-' + n + '">Case Study ' + n + (r.kind === 'prep' ? ' prep' : '') + ', study guide</a>'));
      }
    });
    if (cs.length) groups.push(['Case Studies', cs]);

    var sl = [];
    wrows.forEach(function (r) { if (r.slides && r.date <= todayIso) sl.push(item(r.label, '<a href="' + esc(r.slides) + '">' + esc(r.topic) + '</a>')); });
    if (sl.length) groups.push(['Slides', sl]);

    var box = el('div', { 'class': 'week-list' });
    groups.forEach(function (g) {
      box.appendChild(el('section', { 'class': 'wl-group' }, '<h2>' + g[0] + '</h2><ul>' + g[1].join('') + '</ul>'));
    });
    return box;
  }

  // ---- This week ---------------------------------------------------------
  var wk = document.getElementById('this-week');
  if (wk) {
    var dated = rows.filter(function (r) { return r.date; });
    var first = parse(dated[0].date), last = parse(dated[dated.length - 1].date);
    var d = today;
    if (d.getDay() === 6) d = addDays(d, 2);
    if (d.getDay() === 0) d = addDays(d, 1);
    if (d < first) d = first;
    var monday = addDays(d, 1 - d.getDay());
    var days = wk.querySelector('.week-days');
    var head = wk.querySelector('.week-label');
    if (d > last) {
      var fin = rows.filter(function (r) { return r.kind === 'final'; })[0];
      head.textContent = 'After the last class';
      days.style.gridTemplateColumns = '1fr';
      days.appendChild(el('div', { 'class': 'day' },
        '<span class="day-date">Exam period</span><span class="day-topic">' + esc(fin ? fin.topic : 'Final project') + '</span>' +
        (fin && fin.in_class ? '<span class="day-sub">' + esc(fin.in_class) + '</span>' : '')));
    } else {
      var fri = addDays(monday, 4);
      var anyRow = null, weekRows = [];
      [0, 2, 4].forEach(function (off) {
        var day = addDays(monday, off);
        var r = rowFor(iso(day));
        if (r && r.kind !== 'off') anyRow = anyRow || r;
        var cls = 'day', html = '';
        var dateTxt = label(day);
        if (!r) {
          cls += ' off';
          html = '<span class="day-date">' + dateTxt + '</span><span class="day-topic">No class</span>';
        } else if (r.kind === 'off') {
          cls += ' off';
          var why = r.topic.replace(/^No class:?\s*/, '');
          html = '<span class="day-date">' + dateTxt + '</span><span class="day-topic">No class</span>' +
            (why ? '<span class="day-sub">' + esc(why) + '</span>' : '');
        } else {
          if (r.kind === 'case') { cls += ' case';  }
          html = '<span class="day-date">' + dateTxt + '</span><span class="day-topic">' + esc(r.topic) + '</span>';
          if (r.in_class) html += '<span class="day-sub">' + esc(r.in_class) + '</span>';
          weekRows.push(r);
        }
        if (r && r.due) {
          var m = /^HW (\d+)/.exec(r.due), hw = m && (C.homeworks || []).filter(function (h) { return h.n === m[1]; })[0];
          html += '<span class="day-due">Due: ' + (hw && hw.href ? '<a href="' + hw.href + '">' + esc(r.due) + '</a>' : esc(r.due)) + '</span>';
        }
        days.appendChild(el('div', { 'class': cls }, html));
      });
      var wkNo = anyRow ? anyRow.week : (rowFor(iso(monday)) || {}).week;
      var range = MON[monday.getMonth()] + ' ' + monday.getDate() + '–' +
        (fri.getMonth() !== monday.getMonth() ? MON[fri.getMonth()] + ' ' : '') + fri.getDate();
      head.textContent = range;
      wk.appendChild(weekList(weekRows, iso(monday), iso(fri)));
    }
  }

  // ---- Table of contents: drop a lone top entry (the page's own title) ----
  var tocList = document.querySelector('#TOC > ul');
  if (tocList && tocList.children.length === 1) {
    var sub = tocList.children[0].querySelector('ul');
    if (sub) { sub.classList.remove('collapse'); tocList.replaceWith(sub); }
  }

  // ---- Contour band behind every page title, in a palette color ----------
  var tb = document.querySelector('#title-block-header');
  if (tb && tb.querySelector('h1') && C.contours) {
    var name = (location.pathname.split('/').pop() || 'index.html');
    var col = getComputedStyle(document.body).getPropertyValue('--t-plan-edge').trim();
    if (!col && C.contourColors && C.contourColors.length) {
      var hsh = 0;
      for (var ci = 0; ci < name.length; ci++) hsh = (hsh * 31 + name.charCodeAt(ci)) >>> 0;
      col = C.contourColors[hsh % C.contourColors.length];
    }
    var holder = document.createElement('div');
    holder.innerHTML = C.contours;
    var svgEl = holder.firstElementChild;
    if (svgEl) {
      if (col) svgEl.style.stroke = col;
      tb.classList.add('has-contours');
      tb.insertBefore(svgEl, tb.firstChild);
    }
  }

  // ---- Which page is this? -----------------------------------------------
  var page = (location.pathname.split('/').pop() || 'index.html').replace(/\.html$/, '');
  var tutorials = C.tutorials.filter(function (t) { return t.ready; });
  var tIdx = -1;
  tutorials.forEach(function (t, i) { if (t.file === page) tIdx = i; });
  var sidebar = document.getElementById('quarto-sidebar-toc-left') || document.querySelector('nav#TOC') && document.querySelector('nav#TOC').parentNode;

  function sideBlock(title, inner) {
    return el('div', { 'class': 'side-block' }, '<span class="side-title">' + title + '</span>' + inner);
  }
  function classDays(test) {
    return rows.filter(test).map(function (r) {
      return '<a href="schedule.html">' + esc(r.label) + ', ' + esc(r.topic) + '</a>';
    }).join('');
  }

  // ---- Tutorial pages ------------------------------------------------------
  if (tIdx >= 0) {
    var t = tutorials[tIdx];
    if (sidebar) {
      var used = classDays(function (r) { return r.tutorial && r.tutorial.file === t.file; });
      if (used) sidebar.appendChild(sideBlock('Used in Class', used));
    }
    var main = document.querySelector('main');
    if (main) {
      var prev = tutorials[tIdx - 1], next = tutorials[tIdx + 1];
      var pager = el('div', { 'class': 'sheet-pager' });
      pager.innerHTML = (prev ? '<a href="' + prev.file + '.html"><small>← Previous</small><b>' + esc(prev.title) + '</b></a>' : '<span></span>') +
        (next ? '<a href="' + next.file + '.html"><small>Next →</small><b>' + esc(next.title) + '</b></a>' : '');
      main.appendChild(pager);
    }
  }

  // ---- Reading pages -------------------------------------------------------
  var rm = page.match(/^reading-(.+)$/);
  if (rm && sidebar) {
    var slug = rm[1];
    var hasIt = function (r) { return (r.readings || []).some(function (it) { return it.slug === slug; }); };
    var before = classDays(hasIt);
    if (before) sidebar.insertBefore(sideBlock('Read Before', before), sidebar.firstChild);
    var seen = {}, goes = '';
    rows.filter(hasIt).forEach(function (r) {
      if (r.tutorial && r.tutorial.href && !seen[r.tutorial.file]) {
        seen[r.tutorial.file] = 1;
        goes += '<a href="' + r.tutorial.href + '">' + esc(r.tutorial.title) + '</a>';
      }
    });
    if (goes) sidebar.appendChild(sideBlock('Tutorials', goes));
  }

  // ---- Reading quizzes -----------------------------------------------------
  document.querySelectorAll('.reading-quiz[data-quiz]').forEach(function (box) {
    var quiz = C.quizzes[box.getAttribute('data-quiz')];
    if (!quiz) { box.remove(); return; }
    box.innerHTML = '';
    quiz.questions.forEach(function (q, qi) {
      var wrap = el('fieldset', { 'class': 'quiz-q' });
      wrap.appendChild(el('legend', {}, (qi + 1) + '. ' + esc(q.q)));
      var why = el('p', { 'class': 'quiz-why', 'aria-live': 'polite' });
      q.options.forEach(function (opt, oi) {
        var lab = el('label', { 'class': 'quiz-opt' });
        var input = el('input', { type: 'radio', name: 'q' + qi + '-' + box.getAttribute('data-quiz') });
        input.addEventListener('change', function () {
          wrap.querySelectorAll('.quiz-opt').forEach(function (o) { o.classList.remove('right', 'wrong'); });
          var right = oi === q.answer;
          lab.classList.add(right ? 'right' : 'wrong');
          why.className = 'quiz-why ' + (right ? 'right' : 'wrong');
          why.textContent = (right ? 'Right. ' : 'Not quite. ') + q.why;
        });
        lab.appendChild(input);
        lab.appendChild(el('span', {}, esc(opt)));
        wrap.appendChild(lab);
      });
      wrap.appendChild(why);
      box.appendChild(wrap);
    });
  });
})();
