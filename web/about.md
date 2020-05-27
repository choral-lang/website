---
layout: home
---

# About

---

## Development Team


<ul>
{% for dev in site.data.developers %}
<li><a href="{{ dev.website }}">{{ dev.name }}</a></li>
{% endfor %}
</ul>

---

## Sponsors

Choral is a project sponsored by the following organisations.

<div class="row" markdown="0">
{% for sponsor in site.data.sponsors %}
  <div class="col-6 text-center">
    <a href="{{sponsor.website}}">
      <div class="border">
        <div class="col-12">
          <img style="max-height:5em;" class="img-fluid py-3" src="/img/sponsors/{{sponsor.photo}}" alt="">
        </div>
        <div class="col-12">{{sponsor.name}}</div>
      </div>
    </a>
    <div class="col-12">{{sponsor.amount}}</div>
  </div>
{% endfor %}
</div>

---

## Code Repository

The Choral official code repository is on GitHub, so any bugs you find in
either the language, compiler, or standard library should be reported here,
Pull requests are always welcome!

<div class="text-center text-monospace">
<i class="fab fa-github"></i> [choral-lang/choral](https://github.com/choral-lang/choral/)
</div>

---

## Community

Cras viverra eros non hendrerit elementum. Nunc posuere eget nisi ut imperdiet.
Praesent bibendum dui vel erat tristique, in imperdiet nisi accumsan. Donec sed
maximus lectus, sed fringilla velit. Integer eget fermentum ipsum. Donec pretium
aliquam metus sed tristique. Pellentesque habitant morbi tristique senectus et
netus et malesuada fames ac turpis egestas. Donec finibus augue luctus imperdiet
consectetur. Vivamus dui est, ornare eu porta eu, eleifend quis nisl. Quisque
sed velit ac eros scelerisque consequat sed eu quam. Fusce faucibus consectetur
rhoncus. Nulla ut ligula turpis. Pellentesque eu purus enim. In hac habitasse
platea dictumst. Vestibulum diam felis, pulvinar sodales ullamcorper non,
porttitor vel tellus. Donec id blandit eros.