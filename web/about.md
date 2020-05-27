---
layout: home
---

# About

---

## Support

Choral is supported by the Villum Foundation grant [Choreographies for Connected IT Systems](https://www.fabriziomontesi.com/projects/choco/) and by the University of Southern Denmark.

<div class="row" markdown="0">
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
</div>

---

## Contacts

If you're interested in Choral, you're welcome to get in touch with any of the people below, start a discussion on our GitHub project (see the [next section](#code-repository)), or contact directly the principal investigator [Fabrizio Montesi](https://fabriziomontesi.com).

<ul>
{% for dev in site.data.developers %}
<li><a href="{{ dev.website }}">{{ dev.name }}</a></li>
{% endfor %}
</ul>

---

## Code repository

The Choral official code repository is on GitHub, where you can also post issues and start discussions on the language, compiler, or standard library.

<div class="text-center text-monospace">
<i class="fab fa-github"></i> [choral-lang/choral](https://github.com/choral-lang/choral/)
</div>
