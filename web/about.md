---
layout: home
title: About
---

# About

---

## Support

Choral is supported by the ERC Consolidator Grant [CHORDS](https://www.fabriziomontesi.com/projects/chords), the Villum Foundation grant [Choreographies for Connected IT Systems](https://www.fabriziomontesi.com/projects/choco/), and the [University of Southern Denmark](https://www.sdu.dk/).

<div class="row" markdown="0">
<div class="col-sm text-center">
  <a href="https://www.fabriziomontesi.com/projects/chords/">
    <!-- <div class="border"> -->
      <div class="col-sm">
        <img style="max-height:6em;" class="img-fluid py-3" src="/img/sponsors/chords.png" alt="">
      </div>
  </a>
</div>
{% for sponsor in site.data.sponsors %}
  <div class="col-sm text-center">
    <a href="{{sponsor.website}}">
      <!-- <div class="border"> -->
        <div class="col-sm">
          <img style="max-height:6em;" class="img-fluid py-3" src="/img/sponsors/{{sponsor.photo}}" alt="">
        </div>
        <!-- <div class="col-12">{{sponsor.name}}</div> -->
      <!-- </div> -->
    </a>
  </div>
{% endfor %}
<div class="col-12">
<small>Co-funded by the European Union (ERC, CHORDS, 101124225). Views and opinions expressed are however those of the author(s) only and do not necessarily reflect those of the European Union or the European Research Council. Neither the European Union nor the granting authority can be held responsible for them.</small>
</div>
</div>

---

## Contacts

If you're interested in Choral, you're welcome to get in touch with any of the people below, start a discussion on our GitHub project (see the [next section](#code-repository)), or contact the PI [Fabrizio Montesi](https://fabriziomontesi.com).

<ul>
{% for dev in site.data.developers %}
<li><a href="{{ dev.website }}">{{ dev.name }}</a></li>
{% endfor %}
</ul>

---

## Code repository

The Choral official code repository is on GitHub, where you can also post issues and start discussions on the language, compiler, or standard library.

<p class="text-center text-monospace">
<i class="fab fa-github"></i> [choral-lang/choral](https://github.com/choral-lang/choral/)
</p>
